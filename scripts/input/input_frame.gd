class_name InputFrame
extends RefCounted
## Canonical interface for keyboard now; touch/gamepad/AI can supply this later.
const LIGHT: int = 1
const HEAVY: int = 2
const SPECIAL: int = 4
const BLOCK: int = 8
var player_id: int = 0
var tick: int = 0
var direction_x: int = 0
var direction_y: int = 0
var held: int = 0
var just_pressed: int = 0
var just_released: int = 0
var jump_pressed: bool = false
var source: StringName = &"keyboard"
# Canonical/touch input keeps the base window; adapters may offer more leniency.
var throw_chord_ticks: int = 3

func has_button(button: int) -> bool:
	return (held & button) != 0
