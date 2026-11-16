class_name MatchSimulation
extends RefCounted
signal hit_confirmed(event: Dictionary)
var fighters: Array[FighterState] = []
var stage: StageDefinition
var tick: int = 0
var hitstop: int = 0
var last_events: Array[Dictionary] = []

func _init(left: FighterDefinition, right: FighterDefinition, arena: StageDefinition) -> void:
	stage = arena
	fighters = [FighterState.new(left, 1, Vector2(stage.spawn_left, stage.floor_y)), FighterState.new(right, 2, Vector2(stage.spawn_right, stage.floor_y))]
	update_facing()

func clear_input() -> void:
	for fighter in fighters:
		fighter.clear_input()

func update_facing() -> void:
	for index in range(2):
		var fighter: FighterState = fighters[index]
		if fighter.state not in [FighterState.State.ATTACK, FighterState.State.KO]:
			fighter.facing = 1 if fighters[1 - index].position.x >= fighter.position.x else -1

func separate_bodies(previous_order: float) -> void:
	var left: FighterState = fighters[0] if previous_order >= 0 else fighters[1]
	var right: FighterState = fighters[1] if previous_order >= 0 else fighters[0]
	# Jumping above a standing hurtbox permits cross-ups.
	if absf(left.position.y - right.position.y) > 82.0:
		return
	var overlap: float = 32.0 - (right.position.x - left.position.x)
	if overlap > 0:
		left.position.x -= overlap / 2.0
		right.position.x += overlap / 2.0
		if left.position.x < stage.left_bound:
			left.position.x = stage.left_bound
			right.position.x = stage.left_bound + 32.0
		if right.position.x > stage.right_bound:
			right.position.x = stage.right_bound
			left.position.x = stage.right_bound - 32.0

func step(first: InputFrame, second: InputFrame) -> bool:
	last_events.clear()
	if hitstop > 0:
		hitstop -= 1
		return false # Freeze timer, physics, stun, and attack clocks together.
	tick += 1
	update_facing()
	var previous_order: float = fighters[1].position.x - fighters[0].position.x
	fighters[0].update(first, stage)
	fighters[1].update(second, stage)
	separate_bodies(previous_order)
	last_events = CombatResolver.resolve(fighters, stage)
	separate_bodies(previous_order)
	for event in last_events:
		hitstop = maxi(hitstop, event.hitstop)
		hit_confirmed.emit(event)
	return true
