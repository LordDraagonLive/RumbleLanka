class_name FighterDefinition
extends Resource
@export var id: StringName = &"placeholder"
@export var display_name: String = "Placeholder"
@export var health: int = 1000
@export var walk_speed: float = 175.0
@export var jump_velocity: float = 340.0
@export var ui_color: Color = Color.CYAN
@export var attacks: Dictionary = {}

func attack(key: StringName) -> AttackDefinition:
	var candidate: Variant = attacks.get(key)
	if candidate is AttackDefinition and candidate.is_valid():
		return candidate
	# Malformed content has a safe, playable fallback; no dynamic file loads.
	return AttackDefinition.new()
