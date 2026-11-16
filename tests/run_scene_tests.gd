extends SceneTree
## Exercises the real scene tree and input adapter, without editing fighter HP.
var passed: int = 0
var failed: int = 0
var screenshots: bool = false

func _initialize() -> void:
	screenshots = "--screenshots" in OS.get_cmdline_user_args()
	call_deferred("run")

func check(condition: bool, description: String) -> void:
	if condition:
		passed += 1
		print("PASS: ", description)
	else:
		failed += 1
		push_error("FAIL: " + description)

func frames(count: int) -> void:
	for index in range(count):
		await physics_frame

func button_in(node: Node, text: String) -> Button:
	if node is Button and node.text == text:
		return node
	for child in node.get_children():
		var found: Button = button_in(child, text)
		if found != null:
			return found
	return null

func capture(name: String) -> void:
	if not screenshots:
		return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute("res://builds/qa")
	var result: Error = root.get_texture().get_image().save_png("res://builds/qa/%s.png" % name)
	check(result == OK, "Screenshot saved: " + name)

func run() -> void:
	var flow: Node = load("res://scenes/main/main.tscn").instantiate()
	root.add_child(flow)
	await process_frame
	var start: Button = button_in(flow, "Start Fight")
	check(start != null and button_in(flow, "Quit") != null, "Main scene exposes Start Fight and Quit")
	await capture("menu")
	start.pressed.emit()
	await frames(2)
	var view: Node = flow.screen
	check(view.actors.size() == 2 and view.actors[0].model.facing == 1 and view.actors[1].model.facing == -1, "Menu creates two correctly facing fighters")
	check(view.hud.health_labels[0].position.y >= view.hud.bars[0].position.y + view.hud.bars[0].size.y, "HP text stays below engine-sized health bar")
	await frames(92)
	check(view.manager.phase == MatchManager.Phase.ACTIVE, "Countdown enters active fight in scene")
	var initial_x: float = view.manager.simulation.fighters[0].position.x
	Input.action_press(&"p1_right")
	Input.action_press(&"p2_left")
	await frames(25)
	Input.action_release(&"p1_right")
	Input.action_release(&"p2_left")
	check(view.manager.simulation.fighters[0].position.x > initial_x and view.manager.simulation.fighters[1].position.x < 430, "Independent P1 and P2 input moves both actors")
	# Close in until light range, then block a real attack through the adapter.
	Input.action_press(&"p1_right")
	for index in range(90):
		if view.manager.simulation.fighters[1].position.x - view.manager.simulation.fighters[0].position.x <= 42:
			break
		await frames(1)
	Input.action_release(&"p1_right")
	Input.action_press(&"p2_block")
	Input.action_press(&"p1_light")
	await frames(34)
	Input.action_release(&"p1_light")
	Input.action_release(&"p2_block")
	check(view.manager.simulation.fighters[1].hp == 1000, "In-scene keyboard block prevents normal damage")
	await frames(15)
	Input.action_press(&"p1_heavy")
	await frames(40)
	Input.action_release(&"p1_heavy")
	check(view.manager.simulation.fighters[1].hp == 900 and view.hud.bars[1].value == 900, "Heavy damages once and HUD tracks HP")
	view.debug_boxes = true
	view.refresh()
	await capture("arena")
	# Throw through the live adapters, after walking back into grab range.
	Input.action_press(&"p1_right")
	for index in range(90):
		if view.manager.simulation.fighters[1].position.x - view.manager.simulation.fighters[0].position.x <= 40:
			break
		await frames(1)
	Input.action_release(&"p1_right")
	Input.action_press(&"p2_block")
	Input.action_press(&"p1_light")
	await frames(5)
	Input.action_press(&"p1_heavy")
	await frames(2)
	var grabber: FighterState = view.manager.simulation.fighters[0]
	check(grabber.attack != null and grabber.attack.id == &"throw", "Live staggered light+heavy input upgrades startup into a visibly labelled throw")
	await capture("throw_attempt")
	await frames(13)
	Input.action_release(&"p1_light")
	Input.action_release(&"p1_heavy")
	Input.action_release(&"p2_block")
	check(view.manager.simulation.fighters[1].hp == 790 and view.manager.simulation.fighters[1].state == FighterState.State.KNOCKDOWN and "threw" in view.caption, "Live throw beats guard for 110 HP, knocks down, and displays throw feedback")
	await capture("throw_hit")
	await frames(60)
	view._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	var timer_before: int = view.manager.remaining_ticks
	Input.action_press(&"p1_light")
	await frames(12)
	check(view.manager.paused and view.hud.overlay.visible and view.manager.remaining_ticks == timer_before, "Focus loss opens pause and freezes timer")
	await capture("pause")
	view.hud.primary_button.pressed.emit()
	var previous_instance: int = view.manager.simulation.fighters[0].attack_instance
	await frames(24)
	check(not view.manager.paused and view.manager.simulation.fighters[0].attack_instance == previous_instance, "Resume clears held and buffered attacks")
	Input.action_release(&"p1_light")
	# Deterministic controller for QA only; uses the same mapped actions as humans.
	for index in range(5000):
		if view.manager.phase == MatchManager.Phase.MATCH_OVER:
			break
		if view.manager.phase == MatchManager.Phase.ACTIVE:
			var first: FighterState = view.manager.simulation.fighters[0]
			var second: FighterState = view.manager.simulation.fighters[1]
			if absf(second.position.x - first.position.x) > 42:
				Input.action_press(&"p1_right")
			else:
				Input.action_release(&"p1_right")
			if index % 50 == 0:
				Input.action_press(&"p1_heavy")
			elif index % 50 == 1:
				Input.action_release(&"p1_heavy")
		else:
			Input.action_release(&"p1_right")
			Input.action_release(&"p1_heavy")
		await frames(1)
	Input.action_release(&"p1_right")
	Input.action_release(&"p1_heavy")
	check(view.manager.phase == MatchManager.Phase.MATCH_OVER and view.manager.wins == [2, 0], "Full scene plays two KO rounds to match result without HP overrides")
	view._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(view.hud.primary_button.text == "Rematch" and view.hud.overlay.visible and not view.manager.paused, "Match result remains rematchable after focus loss")
	await capture("result")
	view.hud.primary_button.pressed.emit()
	await frames(2)
	check(view.manager.wins == [0, 0] and view.manager.simulation.fighters[1].hp == 1000, "Rematch restores new match")
	view.toggle_pause()
	button_in(view, "Main Menu").pressed.emit()
	await frames(2)
	check(button_in(flow, "Start Fight") != null, "Pause Main Menu returns to startup screen")
	flow.queue_free()
	await process_frame
	print("SCENE RESULT: %d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 else 0)
