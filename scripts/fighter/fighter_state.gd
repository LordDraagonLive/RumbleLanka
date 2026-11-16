class_name FighterState
extends RefCounted
## Simulation data only. No scene tree, raw device input or presentation calls.
enum State { IDLE, WALK, CROUCH, AIRBORNE, ATTACK, BLOCK, HITSTUN, BLOCKSTUN, KNOCKDOWN, GETUP, KO, VICTORY, LAND }
var definition: FighterDefinition
var player_id: int
var position: Vector2
var velocity: Vector2 = Vector2.ZERO
var facing: int = 1
var hp: int = 1000
var state: State = State.IDLE
var state_ticks: int = 0
var crouching: bool = false
var guarding: bool = false
var attack: AttackDefinition
var attack_tick: int = 0
var attack_instance: int = 0
var hit_victims: Dictionary = {}
var buffered_action: StringName = &""
var buffer_ticks: int = 0
var chord_buttons: int = 0
var chord_ticks: int = 0
var chord_throw_grace: int = 0
var buffered_throw_grace: int = 0
var throw_upgrade_ticks: int = 0
var throw_upgrade_button: int = 0
var landing_recovery: int = 0

func _init(data: FighterDefinition, id: int, spawn: Vector2) -> void:
	definition = data
	player_id = id
	position = spawn
	hp = maxi(1, data.health)

func grounded(stage: StageDefinition) -> bool:
	return position.y >= stage.floor_y

func hurtbox() -> Rect2:
	var height: float = 48.0 if crouching else 84.0
	return Rect2(position + Vector2(-16, -height), Vector2(32, height))

func active() -> bool:
	return state == State.ATTACK and attack != null and attack_tick > attack.startup_ticks and attack_tick <= attack.startup_ticks + attack.active_ticks

func world_hitbox() -> Rect2:
	if attack == null:
		return Rect2()
	var rect: Rect2 = attack.hitbox
	if facing < 0:
		rect.position.x = -rect.end.x
	return Rect2(position + rect.position, rect.size)

func invulnerable() -> bool:
	return state == State.GETUP and state_ticks > 5

func locked() -> bool:
	return state in [State.HITSTUN, State.BLOCKSTUN, State.KNOCKDOWN, State.GETUP, State.KO, State.VICTORY, State.LAND]

func clear_input() -> void:
	buffered_action = &""
	buffer_ticks = 0
	chord_buttons = 0
	chord_ticks = 0
	chord_throw_grace = 0
	buffered_throw_grace = 0
	throw_upgrade_ticks = 0
	throw_upgrade_button = 0

func start_attack(key: StringName) -> void:
	attack = definition.attack(key)
	if String(key).begins_with("air_"):
		landing_recovery = attack.recovery_ticks
	attack_instance += 1
	attack_tick = 1
	hit_victims.clear()
	state = State.ATTACK
	guarding = false
	velocity.x = 0.0
	buffered_action = &""
	buffer_ticks = 0
	buffered_throw_grace = 0
	throw_upgrade_ticks = 0
	throw_upgrade_button = 0

func choose_action(buttons: int) -> StringName:
	# Phase 1: no specials/meter. H+S falls back to H; L+H throws.
	if (buttons & (InputFrame.HEAVY | InputFrame.SPECIAL)) == (InputFrame.HEAVY | InputFrame.SPECIAL):
		return &"heavy"
	if (buttons & (InputFrame.LIGHT | InputFrame.HEAVY)) == (InputFrame.LIGHT | InputFrame.HEAVY):
		return &"throw"
	if buttons & InputFrame.HEAVY:
		return &"heavy"
	if buttons & InputFrame.LIGHT:
		return &"light"
	return &""

func update(frame: InputFrame, stage: StageDefinition) -> void:
	var on_ground: bool = grounded(stage)
	if state == State.KO or state == State.VICTORY:
		clear_input()
		return
	if locked():
		clear_input() # Do not queue attacks during stun/getup.
		state_ticks -= 1
		if state_ticks <= 0:
			if state == State.KNOCKDOWN:
				state = State.GETUP
				state_ticks = 15
			else:
				state = State.IDLE if on_ground else State.AIRBORNE
		integrate(stage)
		return
	if buffer_ticks > 0:
		buffer_ticks -= 1
		buffered_throw_grace = maxi(0, buffered_throw_grace - 1)
		if buffer_ticks == 0:
			buffered_action = &""
	var new_buttons: int = frame.just_pressed & (InputFrame.LIGHT | InputFrame.HEAVY | InputFrame.SPECIAL)
	if state == State.ATTACK:
		# Keep normal startup responsive, but accept a slightly staggered keyboard
		# chord before that normal becomes active. Both keys must still be held.
		if frame.has_button(InputFrame.BLOCK) or frame.has_button(InputFrame.SPECIAL) or not frame.has_button(throw_upgrade_button):
			throw_upgrade_ticks = 0
		var both: int = InputFrame.LIGHT | InputFrame.HEAVY
		var other_button: int = both & ~throw_upgrade_button
		if throw_upgrade_ticks > 0 and on_ground and attack.allow_throw_chord_upgrade and attack_tick <= attack.startup_ticks and hit_victims.is_empty() and (frame.held & both) == both and (new_buttons & other_button) != 0:
			clear_input()
			start_attack(&"throw")
			integrate(stage)
			return
		throw_upgrade_ticks = maxi(0, throw_upgrade_ticks - 1)
	if frame.has_button(InputFrame.BLOCK):
		clear_input() # B+attack is ignored; guard does not cancel recovery.
	elif new_buttons != 0:
		if chord_ticks == 0:
			chord_ticks = 3
			chord_buttons = new_buttons
			chord_throw_grace = clampi(frame.throw_chord_ticks, 3, 6) - 3
		else:
			chord_buttons |= new_buttons
	if chord_ticks > 0:
		chord_ticks -= 1
		if chord_ticks == 0:
			buffered_action = choose_action(chord_buttons)
			buffer_ticks = 6 if buffered_action != &"" else 0
			buffered_throw_grace = chord_throw_grace if chord_buttons in [InputFrame.LIGHT, InputFrame.HEAVY] else 0
			chord_buttons = 0
			chord_throw_grace = 0
	if state == State.ATTACK:
		attack_tick += 1
		if attack_tick <= attack.total_ticks():
			integrate(stage)
			return
		attack = null
		state = State.IDLE if on_ground else State.AIRBORNE
	crouching = on_ground and frame.direction_y > 0
	guarding = on_ground and frame.has_button(InputFrame.BLOCK)
	if buffered_action != &"" and not guarding:
		var key: StringName = buffered_action
		if key == &"throw" and not on_ground:
			clear_input()
		else:
			var grace: int = buffered_throw_grace
			var origin_button: int = InputFrame.LIGHT if key == &"light" else InputFrame.HEAVY
			if key != &"throw":
				if not on_ground:
					key = StringName("air_" + String(key))
				elif crouching:
					key = StringName("crouch_" + String(key))
			start_attack(key)
			if on_ground and attack.allow_throw_chord_upgrade:
				throw_upgrade_ticks = grace
				throw_upgrade_button = origin_button
			integrate(stage)
			return
	if on_ground and frame.jump_pressed and not guarding and not crouching:
		velocity.y = -definition.jump_velocity
		velocity.x = frame.direction_x * definition.walk_speed
		state = State.AIRBORNE
	elif on_ground:
		velocity.x = 0.0 if crouching or guarding else frame.direction_x * definition.walk_speed
		if guarding:
			state = State.BLOCK
		elif crouching:
			state = State.CROUCH
		else:
			state = State.WALK if velocity.x != 0.0 else State.IDLE
	integrate(stage)

func integrate(stage: StageDefinition) -> void:
	var was_airborne: bool = not grounded(stage) or velocity.y < 0
	if not grounded(stage) or velocity.y < 0:
		velocity.y += stage.gravity / 60.0
	position += velocity / 60.0
	if position.y >= stage.floor_y:
		position.y = stage.floor_y
		velocity.y = 0.0
		velocity.x = 0.0
		if was_airborne and landing_recovery > 0 and state in [State.ATTACK, State.AIRBORNE]:
			state = State.LAND
			state_ticks = landing_recovery
			attack = null
			clear_input()
		elif state == State.AIRBORNE:
			state = State.IDLE
		if was_airborne:
			landing_recovery = 0
	position.x = clampf(position.x, stage.left_bound, stage.right_bound)
