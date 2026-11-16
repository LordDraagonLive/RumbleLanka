extends SceneTree
## Physical key events -> Input Map -> adapter -> full simulation, without
## forcing attack state or active frames. Run with Godot --headless --script.
const LEFT: FighterDefinition = preload("res://resources/fighters/placeholder_a.tres")
const RIGHT: FighterDefinition = preload("res://resources/fighters/placeholder_b.tres")
const ARENA: StageDefinition = preload("res://resources/stages/debug_arena.tres")
var passed: int = 0
var failed: int = 0
const ALL_KEYS: Array[Key] = [KEY_J, KEY_K, KEY_KP_1, KEY_KP_2, KEY_U, KEY_O, KEY_I, KEY_P, KEY_L, KEY_H]

func _initialize() -> void:
	call_deferred("run")

func key_event(code: Key, down: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.keycode = code
	event.pressed = down
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func check(condition: bool, description: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", description)
	else:
		failed += 1
		push_error("FAIL: " + description)

func trial(player: int, keys: Array, delay: int = 0, gap: float = 41.0, reverse: bool = false, guard: bool = false, airborne: bool = false, own_block: bool = false, release_first_at: int = -1, window_ticks: int = 6, upgrade_allowed: bool = true, attacker_airborne: bool = false) -> Dictionary:
	for code in ALL_KEYS:
		key_event(code, false)
	var arena: StageDefinition = ARENA.duplicate()
	if airborne or attacker_airborne:
		arena.gravity = 0
	var left_data: FighterDefinition = LEFT
	if not upgrade_allowed:
		left_data = LEFT.duplicate()
		left_data.attacks = LEFT.attacks.duplicate()
		var light: AttackDefinition = LEFT.attack(&"light").duplicate()
		light.allow_throw_chord_upgrade = false
		left_data.attacks[&"light"] = light
	var sim := MatchSimulation.new(left_data, RIGHT, arena)
	sim.fighters[0].position.x = 300 if not reverse else 300 + gap
	sim.fighters[1].position.x = 300 + gap if not reverse else 300
	var attacker: FighterState = sim.fighters[player - 1]
	var defender: FighterState = sim.fighters[2 - player]
	if airborne:
		defender.position.y = 260
	if attacker_airborne:
		attacker.position.y = 260
	var adapters: Array[LocalInputAdapter] = [LocalInputAdapter.new(1), LocalInputAdapter.new(2)]
	for adapter in adapters:
		adapter.throw_chord_ticks = window_ticks
	var saw_throw: bool = false
	var saw_knockdown: bool = false
	var hits: int = 0
	var first_started_tick: int = -1
	var first_hit_tick: int = -1
	for tick in range(65):
		if tick == 0:
			key_event(keys[0], true)
			if own_block:
				key_event(KEY_I if player == 1 else KEY_P, true)
		if tick == release_first_at:
			key_event(keys[0], false)
		if tick == delay:
			key_event(keys[1], true)
		var first: InputFrame = adapters[0].sample(tick)
		var second: InputFrame = adapters[1].sample(tick)
		if guard:
			if player == 1: second.held |= InputFrame.BLOCK
			else: first.held |= InputFrame.BLOCK
		sim.step(first, second)
		if attacker.attack_instance > 0 and first_started_tick < 0:
			first_started_tick = tick
		if not sim.last_events.is_empty() and first_hit_tick < 0:
			first_hit_tick = tick
		if attacker.attack != null and attacker.attack.id == &"throw":
			saw_throw = true
		saw_knockdown = saw_knockdown or defender.state == FighterState.State.KNOCKDOWN
		hits += sim.last_events.size()
	for code in ALL_KEYS:
		key_event(code, false)
	return {"throw": saw_throw, "damage": 1000 - defender.hp, "hits": hits, "knockdown": saw_knockdown, "instances": attacker.attack_instance, "started_tick": first_started_tick, "hit_tick": first_hit_tick}

func run() -> void:
	for binding in [{"player": 1, "keys": [KEY_J, KEY_K], "name": "P1 J+K"}, {"player": 2, "keys": [KEY_KP_1, KEY_KP_2], "name": "P2 Num1+Num2"}, {"player": 2, "keys": [KEY_U, KEY_O], "name": "P2 U+O"}]:
		for delay in range(6):
			var result: Dictionary = trial(binding.player, binding.keys, delay)
			check(result.throw and result.damage == 110 and result.hits == 1 and result.knockdown and result.instances == (1 if delay < 3 else 2), "%s, %d-tick separation: one 110-damage throw and knockdown" % [binding.name, delay])
	for player in [1, 2]:
		var result: Dictionary = trial(player, [KEY_J, KEY_K] if player == 1 else [KEY_U, KEY_O], 0, 41, true)
		check(result.throw and result.damage == 110 and result.hits == 1, "P%d throw works after swapping sides" % player)
	for binding in [{"player": 1, "keys": [KEY_K, KEY_J]}, {"player": 2, "keys": [KEY_KP_2, KEY_KP_1]}]:
		var result: Dictionary = trial(binding.player, binding.keys, 5)
		check(result.throw and result.damage == 110 and result.hits == 1, "P%d heavy-first chord also throws" % binding.player)
	var guarded: Dictionary = trial(1, [KEY_J, KEY_K], 0, 41, false, true)
	check(guarded.throw and guarded.damage == 110 and guarded.knockdown, "Physical-key throw beats held guard")
	var near: Dictionary = trial(1, [KEY_J, KEY_K], 0, 49)
	check(near.throw and near.damage == 110, "Throw connects just inside 50-pixel centre distance")
	var far: Dictionary = trial(1, [KEY_J, KEY_K], 0, 50)
	check(far.throw and far.damage == 0 and far.hits == 0, "Throw correctly whiffs at/outside 50-pixel centre distance")
	var air: Dictionary = trial(1, [KEY_J, KEY_K], 0, 41, false, false, true)
	check(air.throw and air.damage == 0, "Physical-key throw misses airborne opponent")
	var blocking: Dictionary = trial(1, [KEY_J, KEY_K], 0, 41, false, false, false, true)
	check(not blocking.throw and blocking.damage == 0, "Own held block suppresses throw as specified")
	var late: Dictionary = trial(1, [KEY_J, KEY_K], 6)
	check(not late.throw, "Inputs outside six-tick keyboard chord window do not throw")
	var released: Dictionary = trial(1, [KEY_J, KEY_K], 5, 41, false, false, false, false, 3)
	check(not released.throw, "Releasing the first key prevents a delayed chord upgrade")
	var light_only: Dictionary = trial(1, [KEY_J, KEY_K], 100)
	check(light_only.started_tick == 2 and light_only.hit_tick == 7 and light_only.damage == 40 and light_only.instances == 1, "Single light keeps its original startup and never repeats")
	var heavy_only: Dictionary = trial(1, [KEY_K, KEY_J], 100)
	check(heavy_only.started_tick == 2 and heavy_only.hit_tick == 14 and heavy_only.damage == 100 and heavy_only.instances == 1, "Single heavy keeps its original startup and never repeats")
	var delayed_guard: Dictionary = trial(1, [KEY_J, KEY_K], 5, 41, false, true)
	check(delayed_guard.throw and delayed_guard.damage == 110 and delayed_guard.hits == 1, "Delayed chord beats guard without landing a normal first")
	var delayed_whiff: Dictionary = trial(1, [KEY_J, KEY_K], 5, 50)
	check(delayed_whiff.throw and delayed_whiff.damage == 0 and delayed_whiff.hits == 0, "Delayed throw outside grab range does not also land a punch")
	var too_late: Dictionary = trial(1, [KEY_K, KEY_J], 12)
	check(not too_late.throw and too_late.damage == 100, "Late second key cannot cancel a heavy near its active frames")
	var strict: Dictionary = trial(1, [KEY_J, KEY_K], 3, 41, false, false, false, false, -1, 3)
	check(not strict.throw, "Three-tick adapter configuration keeps the strict chord window")
	var opt_out: Dictionary = trial(1, [KEY_J, KEY_K], 5, 41, false, false, false, false, -1, 6, false)
	check(not opt_out.throw and opt_out.damage == 40, "Attack Resource must explicitly allow startup chord correction")
	var air_attacker: Dictionary = trial(1, [KEY_J, KEY_K], 5, 41, false, false, false, false, -1, 6, true, true)
	check(not air_attacker.throw, "An airborne normal cannot upgrade into a grounded throw")
	var literal: Dictionary = trial(1, [KEY_L, KEY_H])
	check(not literal.throw and literal.damage == 0, "Literal letter L+H is not the Light+Heavy binding")
	print("THROW RESULT: %d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 else 0)
