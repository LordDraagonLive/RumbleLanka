class_name LocalInputAdapter
extends RefCounted
var player_id: int
var previous: int = 0
var previous_up: bool = false
var inhibited: Dictionary = {}
var throw_chord_ticks: int = 6
const BUTTONS: Array[String] = ["light", "heavy", "special", "block"]

func _init(id: int = 1) -> void:
	player_id = id
	throw_chord_ticks = clampi(int(ProjectSettings.get_setting("controls/keyboard_throw_chord_ticks", 6)), 3, 6)

func action(key: String) -> StringName:
	return StringName("p%d_%s" % [player_id, key])

func pressed(key: String) -> bool:
	var down: bool = Input.is_action_pressed(action(key))
	if inhibited.has(key):
		if not down:
			inhibited.erase(key)
		return false
	return down

func sample(tick: int) -> InputFrame:
	var frame := InputFrame.new()
	frame.player_id = player_id
	frame.tick = tick
	frame.throw_chord_ticks = throw_chord_ticks
	frame.direction_x = int(pressed("right")) - int(pressed("left"))
	frame.direction_y = int(pressed("down")) - int(pressed("up"))
	var up: bool = pressed("up") and frame.direction_y < 0
	frame.jump_pressed = up and not previous_up
	previous_up = up
	for index in range(BUTTONS.size()):
		if pressed(BUTTONS[index]):
			frame.held |= 1 << index
	frame.just_pressed = frame.held & ~previous
	frame.just_released = previous & ~frame.held
	previous = frame.held
	return frame

func clear() -> void:
	previous = 0
	previous_up = false
	# Keys held through pause/countdown must be released before becoming input.
	for key in ["left", "right", "up", "down", "light", "heavy", "special", "block"]:
		if Input.is_action_pressed(action(key)):
			inhibited[key] = true
