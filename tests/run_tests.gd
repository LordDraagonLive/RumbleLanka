extends SceneTree
## No addons. Run using Godot --headless --path . --script res://tests/run_tests.gd
const LEFT: FighterDefinition = preload("res://resources/fighters/placeholder_a.tres")
const RIGHT: FighterDefinition = preload("res://resources/fighters/placeholder_b.tres")
const ARENA: StageDefinition = preload("res://resources/stages/debug_arena.tres")
var passed: int = 0
var failed: int = 0

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", description)
	else:
		failed += 1
		push_error("FAIL: " + description)

func blank() -> InputFrame:
	return InputFrame.new()

func press(buttons: int, down: bool = false) -> InputFrame:
	var frame := InputFrame.new()
	frame.held = buttons
	frame.just_pressed = buttons
	frame.direction_y = 1 if down else 0
	return frame

func close_sim() -> MatchSimulation:
	var sim := MatchSimulation.new(LEFT, RIGHT, ARENA)
	sim.fighters[0].position.x = 300
	sim.fighters[1].position.x = 341
	return sim

func activate(fighter: FighterState, key: StringName) -> void:
	fighter.start_attack(key)
	fighter.attack_tick = fighter.attack.startup_ticks + 1

func ticks(sim: MatchSimulation, count: int, first: InputFrame = null, second: InputFrame = null) -> void:
	for index in range(count):
		sim.step(blank() if first == null else first, blank() if second == null else second)

func run() -> void:
	test_content_and_controls()
	test_movement_and_facing()
	test_attack_timing()
	test_guards()
	test_trade_and_ko()
	test_inputs_and_stun()
	test_rounds()
	test_audio()
	print("RESULT: %d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 else 0)

func test_content_and_controls() -> void:
	check(LEFT.attack(&"heavy").damage == 100 and LEFT.attack(&"light").total_ticks() == 17, "Resource-backed frame data")
	var malformed := FighterDefinition.new()
	malformed.attacks[&"light"] = "bad data"
	check(malformed.attack(&"light").is_valid(), "Malformed/missing move returns safe fallback")
	var event: InputEventKey = InputMap.action_get_events(&"p2_light")[0] as InputEventKey
	check(event.physical_keycode == KEY_KP_1, "P2 Num1 maps to actual Godot keypad constant")
	check((InputMap.action_get_events(&"p2_heavy")[0] as InputEventKey).physical_keycode == KEY_KP_2, "P2 Num2 mapping")
	check((InputMap.action_get_events(&"p2_block")[0] as InputEventKey).physical_keycode == KEY_KP_5, "P2 Num5 mapping")
	check((InputMap.action_get_events(&"p2_left")[0] as InputEventKey).physical_keycode == KEY_LEFT, "Arrow mapping")
	check((InputMap.action_get_events(&"p2_right")[0] as InputEventKey).physical_keycode == KEY_RIGHT, "Right arrow mapping")
	check((InputMap.action_get_events(&"p2_up")[0] as InputEventKey).physical_keycode == KEY_UP, "Up arrow mapping")
	check((InputMap.action_get_events(&"p2_down")[0] as InputEventKey).physical_keycode == KEY_DOWN, "Down arrow mapping")
	print("KEY CONSTANTS: ", KEY_KP_1, " ", KEY_KP_2, " ", KEY_KP_3, " ", KEY_KP_5)
	var adapter := LocalInputAdapter.new(1)
	Input.action_press(&"p1_light")
	var frame: InputFrame = adapter.sample(1)
	check(frame.just_pressed == InputFrame.LIGHT and frame.player_id == 1, "Keyboard adapter emits canonical rising edge")
	check(adapter.sample(2).just_pressed == 0, "Held key has no repeated rising edge")
	adapter.clear()
	check(adapter.sample(3).held == 0, "Resume inhibits held attack")
	Input.action_release(&"p1_light")
	adapter.sample(4)
	Input.action_press(&"p1_light")
	check(adapter.sample(5).just_pressed == InputFrame.LIGHT, "Release/repress restores input after pause")
	Input.action_release(&"p1_light")
	Input.action_press(&"p1_left")
	Input.action_press(&"p1_right")
	check(adapter.sample(6).direction_x == 0, "Opposite directions neutralize")
	Input.action_release(&"p1_left")
	Input.action_release(&"p1_right")

func test_movement_and_facing() -> void:
	var sim := close_sim()
	var walk := blank()
	walk.direction_x = -1
	ticks(sim, 60, walk)
	check(is_equal_approx(sim.fighters[0].position.x, 125.0), "Walk integrates 175 px over 60 ticks")
	ticks(sim, 600, walk)
	check(sim.fighters[0].position.x == 52, "Stage boundary clamps")
	sim = close_sim()
	var jump := blank()
	jump.jump_pressed = true
	jump.direction_y = -1
	sim.step(jump, blank())
	check(sim.fighters[0].position.y < 300 and sim.fighters[0].state == FighterState.State.AIRBORNE, "Jump leaves ground")
	ticks(sim, 60)
	check(sim.fighters[0].position.y == 300, "Gravity lands on floor")
	var crouch := blank()
	crouch.direction_y = 1
	sim.step(crouch, blank())
	check(sim.fighters[0].state == FighterState.State.CROUCH and sim.fighters[0].hurtbox().size.y == 48, "Crouch updates state and hurtbox")
	sim.fighters[0].position.x = 400
	sim.fighters[1].position.x = 350
	sim.update_facing()
	check(sim.fighters[0].facing == -1 and sim.fighters[1].facing == 1, "Facing reverses after side switch")
	activate(sim.fighters[0], &"light")
	check(sim.fighters[0].world_hitbox().end.x < 400, "Mirrored attack extends character-local forward")
	sim = close_sim()
	walk.direction_x = 1
	ticks(sim, 120, walk)
	check(sim.fighters[1].position.x - sim.fighters[0].position.x >= 31.99, "Grounded bodies cannot pass through each other")
	sim = close_sim()
	var fighter: FighterState = sim.fighters[0]
	fighter.position.y = 299
	fighter.velocity.y = 120
	fighter.start_attack(&"air_heavy")
	sim.step(blank(), blank())
	check(fighter.state == FighterState.State.LAND and fighter.state_ticks == 9 and not fighter.active(), "Landing aerial heavy clears hitbox and enforces nine recovery ticks")
	ticks(sim, 8, press(InputFrame.LIGHT))
	check(fighter.state == FighterState.State.LAND and fighter.attack_instance == 1, "Landing recovery rejects offensive input")
	sim.step(blank(), blank())
	check(fighter.state == FighterState.State.IDLE, "Landing recovery returns to neutral on schedule")

func test_attack_timing() -> void:
	var sim := close_sim()
	var fighter: FighterState = sim.fighters[0]
	fighter.start_attack(&"light")
	for index in range(1, 6):
		fighter.attack_tick = index
		check(not fighter.active(), "Light startup frame %d is inactive" % index)
	for index in range(6, 9):
		fighter.attack_tick = index
		check(fighter.active(), "Light active frame %d" % index)
	fighter.attack_tick = 9
	check(not fighter.active(), "Recovery disables hitbox")
	activate(fighter, &"light")
	var events: Array[Dictionary] = CombatResolver.resolve(sim.fighters, ARENA)
	check(events.size() == 1 and sim.fighters[1].hp == 960, "Active strike deals configured damage")
	for index in range(10):
		CombatResolver.resolve(sim.fighters, ARENA)
	check(sim.fighters[1].hp == 960, "One attack instance cannot hit victim repeatedly")
	# A second strike requires a distinct instance.
	sim.fighters[1].position.x = 341
	var previous_instance: int = fighter.attack_instance
	activate(fighter, &"light")
	CombatResolver.resolve(sim.fighters, ARENA)
	check(sim.fighters[1].hp == 920 and fighter.attack_instance == previous_instance + 1, "New attack instance can hit again")
	sim = close_sim()
	sim.fighters[0].start_attack(&"heavy")
	ticks(sim, 11)
	check(sim.fighters[1].hp == 1000, "Heavy does not deal damage during 12 startup frames")
	sim.step(blank(), blank())
	check(sim.fighters[1].hp == 900 and sim.hitstop == 6, "Heavy activates after startup and applies hitstop")
	var attack_tick: int = sim.fighters[0].attack_tick
	var stun: int = sim.fighters[1].state_ticks
	var position: Vector2 = sim.fighters[1].position
	ticks(sim, 6)
	check(sim.fighters[0].attack_tick == attack_tick and sim.fighters[1].state_ticks == stun and sim.fighters[1].position == position, "Hitstop freezes animation, physics and stun clocks")
	sim.step(blank(), blank())
	check(sim.fighters[1].state_ticks == stun - 1, "Hitstun begins after hitstop")

func guard_trial(key: StringName, crouch: bool) -> bool:
	var sim := close_sim()
	var defender: FighterState = sim.fighters[1]
	defender.guarding = true
	defender.crouching = crouch
	defender.state = FighterState.State.BLOCK
	activate(sim.fighters[0], key)
	var events: Array[Dictionary] = CombatResolver.resolve(sim.fighters, ARENA)
	return events.size() == 1 and events[0].blocked and defender.hp == 1000

func test_guards() -> void:
	check(guard_trial(&"light", false), "Standing guard blocks mid without chip")
	check(guard_trial(&"crouch_light", true), "Crouch guard blocks mid")
	check(guard_trial(&"crouch_heavy", true), "Crouch guard blocks low")
	check(not guard_trial(&"crouch_heavy", false), "Standing guard loses to low")
	var sim := close_sim()
	var defender: FighterState = sim.fighters[1]
	defender.guarding = true
	defender.state = FighterState.State.BLOCK
	var overhead: AttackDefinition = LEFT.attack(&"air_light")
	check(CombatResolver.can_block(defender, sim.fighters[0], overhead, ARENA), "Standing guard blocks overhead")
	defender.crouching = true
	check(not CombatResolver.can_block(defender, sim.fighters[0], overhead, ARENA), "Crouch guard loses to overhead")
	check(not CombatResolver.can_block(defender, sim.fighters[0], LEFT.attack(&"throw"), ARENA), "Throws bypass guard")
	defender.position.x = 332
	activate(sim.fighters[0], &"throw")
	CombatResolver.resolve(sim.fighters, ARENA)
	check(defender.hp == 890 and defender.state == FighterState.State.KNOCKDOWN, "Ground throw hits through guard and knocks down")
	sim = close_sim()
	sim.fighters[1].position = Vector2(332, 290)
	activate(sim.fighters[0], &"throw")
	check(CombatResolver.resolve(sim.fighters, ARENA).is_empty(), "Throw misses airborne target")
	sim = close_sim()
	sim.fighters[1].state = FighterState.State.GETUP
	sim.fighters[1].state_ticks = 15
	activate(sim.fighters[0], &"heavy")
	check(CombatResolver.resolve(sim.fighters, ARENA).is_empty(), "First ten getup ticks are invulnerable")

func test_trade_and_ko() -> void:
	var sim := close_sim()
	for fighter in sim.fighters:
		fighter.hp = 40
		activate(fighter, &"light")
	var events: Array[Dictionary] = CombatResolver.resolve(sim.fighters, ARENA)
	check(events.size() == 2 and sim.fighters[0].hp == 0 and sim.fighters[1].hp == 0, "Simultaneous contacts produce double KO")
	check(not sim.fighters[0].active() and not sim.fighters[1].active(), "KO removes both active hitboxes")
	ticks(sim, 60, press(InputFrame.LIGHT), press(InputFrame.HEAVY))
	check(sim.fighters[0].hp == 0 and sim.fighters[0].state == FighterState.State.KO, "KO ignores offensive input")
	sim = close_sim()
	sim.fighters[1].hp = 1
	activate(sim.fighters[0], &"heavy")
	CombatResolver.resolve(sim.fighters, ARENA)
	check(sim.fighters[1].hp == 0, "Damage clamps HP to zero")

func test_inputs_and_stun() -> void:
	var sim := close_sim()
	var fighter: FighterState = sim.fighters[0]
	sim.step(press(InputFrame.LIGHT), blank())
	sim.step(press(InputFrame.HEAVY), blank())
	sim.step(blank(), blank())
	check(fighter.attack != null and fighter.attack.id == &"throw", "L+H within 3-frame window resolves to throw")
	sim = close_sim()
	ticks(sim, 3, press(InputFrame.HEAVY | InputFrame.SPECIAL))
	check(sim.fighters[0].attack.id == &"heavy", "H+S falls back to heavy without super/meter")
	sim = close_sim()
	ticks(sim, 3, press(InputFrame.BLOCK | InputFrame.HEAVY))
	check(sim.fighters[0].state == FighterState.State.BLOCK and sim.fighters[0].attack == null, "B+attack ignores attack")
	sim = close_sim()
	var held := press(InputFrame.LIGHT)
	sim.step(held, blank())
	held.just_pressed = 0
	ticks(sim, 90, held)
	check(sim.fighters[0].attack_instance == 1, "Holding attack never auto-repeats")
	sim = close_sim()
	fighter = sim.fighters[0]
	fighter.state = FighterState.State.HITSTUN
	fighter.state_ticks = 10
	ticks(sim, 8, press(InputFrame.HEAVY))
	check(fighter.attack == null and fighter.buffer_ticks == 0, "Offensive input during hitstun is discarded")
	ticks(sim, 20)
	check(fighter.attack_instance == 0, "Stun cannot leave queued attack")
	sim = close_sim()
	fighter = sim.fighters[0]
	fighter.start_attack(&"heavy")
	sim.step(press(InputFrame.LIGHT), blank())
	ticks(sim, 60)
	check(fighter.attack_instance == 1, "Buffered input expires after six ticks during long recovery")

func test_rounds() -> void:
	var manager := MatchManager.new(LEFT, RIGHT, ARENA)
	for index in range(90): manager.step(blank(), blank())
	check(manager.phase == MatchManager.Phase.ACTIVE and manager.remaining_ticks == 5940, "90-tick pre-round leads to 99-second active round")
	manager.simulation.hitstop = 4
	for index in range(4): manager.step(blank(), blank())
	check(manager.remaining_ticks == 5940, "Round timer freezes during hitstop")
	manager.set_paused(true)
	var tick: int = manager.simulation.tick
	for index in range(100): manager.step(press(InputFrame.HEAVY), blank())
	check(manager.remaining_ticks == 5940 and manager.simulation.tick == tick and manager.simulation.fighters[0].hp == 1000, "Pause freezes health, combat and timer")
	manager.set_paused(false)
	manager.simulation.fighters[1].hp = 0
	manager.step(blank(), blank())
	check(manager.wins == [1, 0] and manager.phase == MatchManager.Phase.ROUND_OVER, "KO awards one round")
	for index in range(120): manager.step(blank(), blank())
	check(manager.round_number == 2 and manager.simulation.fighters[1].hp == 1000 and manager.simulation.fighters[0].position.x == 210, "Next round restores HP and spawn positions")
	manager.phase = MatchManager.Phase.ACTIVE
	manager.simulation.fighters[1].hp = 0
	manager.step(blank(), blank())
	for index in range(120): manager.step(blank(), blank())
	check(manager.phase == MatchManager.Phase.MATCH_OVER and manager.winner == 1 and manager.wins == [2, 0], "First to two wins ends best-of-three match")
	var large: FighterDefinition = LEFT.duplicate()
	large.health = 1200
	var small: FighterDefinition = RIGHT.duplicate()
	small.health = 900
	manager = MatchManager.new(large, small, ARENA)
	manager.simulation.fighters[0].hp = 600
	manager.simulation.fighters[1].hp = 500
	manager.phase = MatchManager.Phase.ACTIVE
	manager.remaining_ticks = 1
	manager.step(blank(), blank())
	check(manager.winner == 2 and manager.result == "TIME UP", "Timeout compares health percentage, not raw HP")
	manager = MatchManager.new(LEFT, RIGHT, ARENA)
	for round_index in range(3):
		manager.phase = MatchManager.Phase.ACTIVE
		manager.remaining_ticks = 1
		manager.step(blank(), blank())
		check(manager.winner == 0 and manager.wins == [0, 0], "Equal timeout is draw %d without awarding wins" % (round_index + 1))
		manager.next_round()
	check(manager.sudden_death and manager.consecutive_draws == 3, "Three consecutive draws enable sudden death")
	manager.phase = MatchManager.Phase.ACTIVE
	manager.simulation.fighters[0].position.x = 300
	manager.simulation.fighters[1].position.x = 341
	activate(manager.simulation.fighters[0], &"light")
	manager.step(blank(), blank())
	check(manager.winner == 1 and manager.phase == MatchManager.Phase.ROUND_OVER, "First unblocked hit wins sudden death")
	manager = MatchManager.new(LEFT, RIGHT, ARENA)
	manager.phase = MatchManager.Phase.ACTIVE
	manager.simulation.fighters[0].hp = 0
	manager.simulation.fighters[1].hp = 0
	manager.step(blank(), blank())
	check(manager.winner == 0 and manager.wins == [0, 0] and manager.result == "DOUBLE KO", "Double KO awards neither player a round")

func test_audio() -> void:
	var audio := PlaceholderAudio.new()
	root.add_child(audio)
	check(audio.request(&"missing.event") == "[missing.event]" and audio.player.stream != null, "Missing audio event safely supplies silence and caption")
	audio.free()
