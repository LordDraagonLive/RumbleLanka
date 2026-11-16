class_name PlaceholderAudio
extends Node
## Silent authored placeholder. All events still supply readable text.
const SILENCE: AudioStream = preload("res://assets/audio/placeholders/silence.tres")
var player: AudioStreamPlayer
var last_caption: String = ""

func _ready() -> void:
	player = AudioStreamPlayer.new()
	player.stream = SILENCE
	add_child(player)

func request(event: StringName, fighter_id: int = 0) -> String:
	match event:
		&"intro": last_caption = "Ready!"
		&"ko": last_caption = "KO!"
		&"block": last_caption = "P%d blocked" % fighter_id
		&"hit": last_caption = "P%d hit" % fighter_id
		_: last_caption = "[%s]" % event
	# Unknown/missing events use silence and text, never a missing-file lookup.
	# Silence needs no playback allocation. A real provider can play clips later.
	return last_caption
