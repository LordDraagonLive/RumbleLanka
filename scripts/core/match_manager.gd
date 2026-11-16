class_name MatchManager
extends RefCounted
signal round_started(number: int)
signal round_ended(winner: int, reason: String)
signal match_ended(winner: int)
enum Phase { PRE_ROUND, ACTIVE, ROUND_OVER, MATCH_OVER }
const ROUND_TICKS: int = 99 * 60
var simulation: MatchSimulation
var definitions: Array[FighterDefinition]
var stage: StageDefinition
var phase: Phase = Phase.PRE_ROUND
var phase_ticks: int = 90
var remaining_ticks: int = ROUND_TICKS
var wins: Array[int] = [0, 0]
var round_number: int = 1
var consecutive_draws: int = 0
var sudden_death: bool = false
var winner: int = 0
var result: String = ""
var paused: bool = false

func _init(left: FighterDefinition, right: FighterDefinition, arena: StageDefinition) -> void:
	definitions = [left, right]
	stage = arena
	simulation = MatchSimulation.new(left, right, arena)

func set_paused(value: bool) -> void:
	# Results must remain rematchable after alt-tab; there is no fight to pause.
	paused = value and phase != Phase.MATCH_OVER
	simulation.clear_input()

func next_round() -> void:
	round_number += 1
	simulation = MatchSimulation.new(definitions[0], definitions[1], stage)
	remaining_ticks = ROUND_TICKS
	phase = Phase.PRE_ROUND
	phase_ticks = 90
	sudden_death = consecutive_draws >= 3
	result = ""
	round_started.emit(round_number)

func finish_round(round_winner: int, reason: String) -> void:
	if phase != Phase.ACTIVE:
		return
	winner = round_winner
	result = reason
	phase = Phase.ROUND_OVER
	phase_ticks = 120
	simulation.clear_input()
	if winner == 0:
		consecutive_draws += 1
	else:
		consecutive_draws = 0
		wins[winner - 1] += 1
		var victor: FighterState = simulation.fighters[winner - 1]
		victor.state = FighterState.State.VICTORY
		victor.attack = null
	round_ended.emit(winner, reason)

func timeout_winner() -> int:
	var first: float = float(simulation.fighters[0].hp) / maxi(1, definitions[0].health)
	var second: float = float(simulation.fighters[1].hp) / maxi(1, definitions[1].health)
	if absf(first - second) <= 0.0001:
		return 0
	return 1 if first > second else 2

func step(first: InputFrame, second: InputFrame) -> void:
	if paused or phase == Phase.MATCH_OVER:
		return
	if phase == Phase.PRE_ROUND:
		phase_ticks -= 1
		if phase_ticks <= 0:
			phase = Phase.ACTIVE
		return
	if phase == Phase.ROUND_OVER:
		phase_ticks -= 1
		if phase_ticks <= 0:
			if wins[0] >= 2 or wins[1] >= 2:
				phase = Phase.MATCH_OVER
				match_ended.emit(winner)
			else:
				next_round()
		return
	if not simulation.step(first, second):
		return
	var first_ko: bool = simulation.fighters[0].hp <= 0
	var second_ko: bool = simulation.fighters[1].hp <= 0
	if first_ko or second_ko:
		finish_round(0 if first_ko and second_ko else (2 if first_ko else 1), "DOUBLE KO" if first_ko and second_ko else "KO")
		return
	if sudden_death:
		var hitters: Dictionary = {}
		for event in simulation.last_events:
			if not event.blocked:
				hitters[event.attacker] = true
		if not hitters.is_empty():
			finish_round(0 if hitters.size() == 2 else int(hitters.keys()[0]), "SUDDEN DEATH")
		return
	remaining_ticks = maxi(0, remaining_ticks - 1)
	if remaining_ticks == 0:
		finish_round(timeout_winner(), "TIME UP")
