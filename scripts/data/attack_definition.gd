class_name AttackDefinition
extends Resource
## Rectangles are character-local, feet at (0, 0), facing right.
@export var id: StringName = &"light"
@export var startup_ticks: int = 5
@export var active_ticks: int = 3
@export var recovery_ticks: int = 9
@export var damage: int = 40
@export_enum("mid", "high", "low", "overhead", "throw") var hit_level: String = "mid"
@export var hitstun_ticks: int = 12
@export var blockstun_ticks: int = 8
@export var hitstop_ticks: int = 4
@export var knockback: float = 13.0
@export var knockdown: bool = false
@export var hitbox: Rect2 = Rect2(12, -65, 43, 25)
@export var sound_event: StringName = &"light"
# Input correction only: opt-in startup conversion, never a hit/recovery cancel.
@export var allow_throw_chord_upgrade: bool = false

func total_ticks() -> int:
	return startup_ticks + active_ticks + recovery_ticks

func is_valid() -> bool:
	return startup_ticks > 0 and active_ticks > 0 and recovery_ticks >= 0 and damage >= 0 and hitbox.has_area()
