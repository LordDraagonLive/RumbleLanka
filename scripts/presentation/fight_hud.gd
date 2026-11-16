class_name FightHUD
extends CanvasLayer
signal resume_requested
signal rematch_requested
signal menu_requested
var bars: Array[ProgressBar] = []
var health_labels: Array[Label] = []
var names: Array[Label] = []
var pips: Array[Label] = []
var timer: Label
var banner: Label
var caption: Label
var debug_label: Label
var overlay: ColorRect
var overlay_title: Label
var primary_button: Button
var last_mode: String = ""

func label_at(text: String, rect: Rect2, font_size: int = 14) -> Label:
	var label := Label.new()
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size", font_size)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	return label

func _ready() -> void:
	for index in range(2):
		var x: float = 22.0 if index == 0 else 368.0
		names.append(label_at("", Rect2(x, 8, 250, 20), 14))
		var bar := ProgressBar.new()
		bar.position = Vector2(x, 31)
		bar.size = Vector2(250, 16)
		bar.show_percentage = false
		bar.fill_mode = ProgressBar.FILL_BEGIN_TO_END if index == 0 else ProgressBar.FILL_END_TO_BEGIN
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color("47ddda") if index == 0 else Color("ffb65c")
		bar.add_theme_stylebox_override("fill", fill)
		var background := StyleBoxFlat.new()
		background.bg_color = Color("253248")
		bar.add_theme_stylebox_override("background", background)
		add_child(bar)
		# Reset after hiding percentage/applying styles: initial theme minimum
		# height can otherwise retain 27 pixels despite the requested 16.
		bar.size = Vector2(250, 16)
		bars.append(bar)
		health_labels.append(label_at("", Rect2(x, 49, 250, 16), 11))
		pips.append(label_at("", Rect2(x, 65, 250, 17), 11))
	timer = label_at("99", Rect2(280, 13, 80, 42), 30)
	banner = label_at("", Rect2(70, 107, 500, 70), 27)
	caption = label_at("", Rect2(120, 190, 400, 22), 14)
	debug_label = label_at("", Rect2(20, 84, 600, 18), 10)
	label_at("P1: WASD / J K I     P2: Arrows / Num1 Num2 Num5 (or U O P)", Rect2(0, 318, 640, 16), 11)
	label_at("Throw: J+K / Num1+Num2 (U+O) | Down+heavy sweep | Esc pause | F3 boxes", Rect2(0, 337, 640, 16), 11)
	overlay = ColorRect.new()
	overlay.color = Color(0.02, 0.04, 0.08, 0.94)
	overlay.size = Vector2(640, 360)
	add_child(overlay)
	overlay_title = Label.new()
	overlay_title.position = Vector2(100, 85)
	overlay_title.size = Vector2(440, 48)
	overlay_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_title.add_theme_font_size_override("font_size", 28)
	overlay.add_child(overlay_title)
	primary_button = Button.new()
	primary_button.position = Vector2(220, 160)
	primary_button.size = Vector2(200, 40)
	primary_button.pressed.connect(func() -> void:
		if last_mode == "pause": resume_requested.emit()
		else: rematch_requested.emit())
	overlay.add_child(primary_button)
	var menu := Button.new()
	menu.text = "Main Menu"
	menu.position = Vector2(220, 213)
	menu.size = Vector2(200, 36)
	menu.pressed.connect(func() -> void: menu_requested.emit())
	overlay.add_child(menu)
	overlay.hide()

func update_match(manager: MatchManager, subtitle: String, debug: bool) -> void:
	for index in range(2):
		var fighter: FighterState = manager.simulation.fighters[index]
		names[index].text = "P%d  %s" % [index + 1, fighter.definition.display_name]
		bars[index].max_value = maxi(1, fighter.definition.health)
		bars[index].value = fighter.hp
		health_labels[index].text = "%d / %d HP" % [fighter.hp, maxi(1, fighter.definition.health)]
		pips[index].text = "ROUNDS  %s %s" % ["[X]" if manager.wins[index] > 0 else "[ ]", "[X]" if manager.wins[index] > 1 else "[ ]"]
	timer.text = "SD" if manager.sudden_death else str(ceili(manager.remaining_ticks / 60.0)).pad_zeros(2)
	caption.text = subtitle
	banner.text = ""
	if manager.phase == MatchManager.Phase.PRE_ROUND:
		banner.text = "ROUND %d" % manager.round_number if manager.phase_ticks > 30 else "FIGHT!"
		if manager.sudden_death:
			banner.text = "SUDDEN DEATH"
	elif manager.phase == MatchManager.Phase.ROUND_OVER:
		banner.text = "%s\n%s" % [manager.result, "DRAW" if manager.winner == 0 else "P%d WINS ROUND" % manager.winner]
	debug_label.visible = debug
	if debug:
		var first: FighterState = manager.simulation.fighters[0]
		var second: FighterState = manager.simulation.fighters[1]
		debug_label.text = "P1 %s %s f%d #%d | P2 %s %s f%d #%d | stop %d %d FPS" % [FighterState.State.keys()[first.state], first.attack.id if first.attack != null else &"-", first.attack_tick, first.attack_instance, FighterState.State.keys()[second.state], second.attack.id if second.attack != null else &"-", second.attack_tick, second.attack_instance, manager.simulation.hitstop, Engine.get_frames_per_second()]
	var mode: String = "pause" if manager.paused else ("result" if manager.phase == MatchManager.Phase.MATCH_OVER else "")
	overlay.visible = mode != ""
	if mode != last_mode:
		last_mode = mode
		if mode != "":
			overlay_title.text = "PAUSED" if mode == "pause" else "P%d WINS THE MATCH" % manager.winner
			primary_button.text = "Resume" if mode == "pause" else "Rematch"
			primary_button.grab_focus()
