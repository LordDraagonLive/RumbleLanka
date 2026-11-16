extends Node
## Owns screen navigation only. Combat belongs to MatchManager/MatchSimulation.
const MATCH_SCENE: PackedScene = preload("res://scenes/match/match.tscn")
var screen: Node

func _ready() -> void:
	show_menu()

func replace_screen(next_screen: Node) -> void:
	if is_instance_valid(screen):
		remove_child(screen)
		screen.queue_free()
	screen = next_screen
	add_child(screen)

func show_menu() -> void:
	var menu := Control.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background := ColorRect.new()
	background.color = Color("101c30")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_child(background)
	var column := VBoxContainer.new()
	column.position = Vector2(130, 38)
	column.size = Vector2(380, 280)
	column.add_theme_constant_override("separation", 10)
	menu.add_child(column)
	var title := Label.new()
	title.text = "LANKA RUMBLE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("47ddda"))
	column.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "VS-01  /  LOCAL TWO PLAYER PROTOTYPE"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 12)
	column.add_child(subtitle)
	var start := Button.new()
	start.text = "Start Fight"
	start.custom_minimum_size.y = 38
	start.pressed.connect(start_fight)
	column.add_child(start)
	var quit_button := Button.new()
	quit_button.text = "Quit"
	quit_button.custom_minimum_size.y = 32
	quit_button.pressed.connect(func() -> void: get_tree().quit())
	column.add_child(quit_button)
	var controls := Label.new()
	controls.text = "P1  WASD move  /  J light  K heavy  I block\nP2  Arrows move  /  Num1 light  Num2 heavy  Num5 block\nThrow up close: P1 J+K / P2 Num1+Num2 (or U+O)\nDown+heavy sweep / Esc pause / P2 U O P also work"
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_font_size_override("font_size", 12)
	column.add_child(controls)
	replace_screen(menu)
	start.grab_focus()

func start_fight() -> void:
	var match_view: Node = MATCH_SCENE.instantiate()
	match_view.return_to_menu.connect(show_menu)
	replace_screen(match_view)
