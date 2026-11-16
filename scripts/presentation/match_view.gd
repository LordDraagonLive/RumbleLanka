extends Node2D
signal return_to_menu
const LEFT: FighterDefinition = preload("res://resources/fighters/placeholder_a.tres")
const RIGHT: FighterDefinition = preload("res://resources/fighters/placeholder_b.tres")
const ARENA: StageDefinition = preload("res://resources/stages/debug_arena.tres")
var manager: MatchManager
var adapters: Array[LocalInputAdapter] = [LocalInputAdapter.new(1), LocalInputAdapter.new(2)]
var actors: Array[FighterController] = []
var audio: PlaceholderAudio
var hud: FightHUD
var debug_boxes: bool = false
var caption_ticks: int = 0
var caption: String = ""
var round_seen: int = 0

func _ready() -> void:
	actors = [$PlaceholderA, $PlaceholderB]
	audio = PlaceholderAudio.new()
	add_child(audio)
	hud = FightHUD.new()
	add_child(hud)
	hud.resume_requested.connect(toggle_pause)
	hud.rematch_requested.connect(rematch)
	hud.menu_requested.connect(func() -> void: return_to_menu.emit())
	rematch()

func rematch() -> void:
	manager = MatchManager.new(LEFT, RIGHT, ARENA)
	manager.round_ended.connect(on_round_ended)
	round_seen = 0
	caption = audio.request(&"intro")
	caption_ticks = 60
	clear_inputs()
	refresh()

func clear_inputs() -> void:
	for adapter in adapters:
		adapter.clear()
	manager.simulation.clear_input()

func _physics_process(_delta: float) -> void:
	var before: MatchManager.Phase = manager.phase
	var frames: Array[InputFrame] = [adapters[0].sample(manager.simulation.tick), adapters[1].sample(manager.simulation.tick)]
	manager.step(frames[0], frames[1])
	if before != manager.phase:
		clear_inputs()
	if round_seen != manager.round_number:
		round_seen = manager.round_number
		manager.simulation.hit_confirmed.connect(on_hit)
	if not manager.paused:
		caption_ticks = maxi(0, caption_ticks - 1)
	refresh()

func on_hit(event: Dictionary) -> void:
	caption = audio.request(&"block" if event.blocked else &"hit", event.defender)
	if event.attack == &"throw":
		caption = "P%d threw P%d (-%d HP)" % [event.attacker, event.defender, event.damage]
	caption_ticks = 40

func on_round_ended(_winner: int, reason: String) -> void:
	caption = audio.request(&"ko") if "KO" in reason else reason
	caption_ticks = 120

func toggle_pause() -> void:
	if manager.phase == MatchManager.Phase.MATCH_OVER:
		return
	manager.set_paused(not manager.paused)
	clear_inputs()
	refresh()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode in [KEY_ESCAPE, KEY_ENTER]:
			toggle_pause()
			get_viewport().set_input_as_handled()
		elif event.physical_keycode == KEY_F3 and OS.is_debug_build():
			debug_boxes = not debug_boxes

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and manager != null:
		manager.set_paused(true)
		clear_inputs()
		if hud != null:
			refresh()

func refresh() -> void:
	for index in range(2):
		actors[index].model = manager.simulation.fighters[index]
		actors[index].position = actors[index].model.position
		actors[index].show_boxes = debug_boxes
		actors[index].queue_redraw()
	hud.update_match(manager, caption if caption_ticks > 0 else "", debug_boxes)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("101c30"))
	draw_circle(Vector2(510, 140), 60, Color("20334b"))
	for index in range(10):
		var x: float = index * 75.0 - 20
		draw_rect(Rect2(x, 160 - (index % 3) * 20, 52, 140), Color("192a40"))
	draw_rect(Rect2(0, 300, 640, 60), Color("283645"))
	draw_line(Vector2(0, 300), Vector2(640, 300), Color("5b7b8b"), 2)
	for x in range(0, 641, 40):
		draw_line(Vector2(x, 301), Vector2(x + (x - 320) * 0.2, 360), Color("364958"), 1)
	draw_line(Vector2(52, 284), Vector2(52, 312), Color("77a4b8"), 2)
	draw_line(Vector2(588, 284), Vector2(588, 312), Color("77a4b8"), 2)
