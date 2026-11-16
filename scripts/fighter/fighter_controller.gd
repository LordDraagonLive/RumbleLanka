class_name FighterController
extends Node2D
## Placeholder presentation. The authoritative model never reads this node.
var model: FighterState
var show_boxes: bool = false

func _draw() -> void:
	if model == null:
		return
	var color: Color = model.definition.ui_color
	var face: int = model.facing
	draw_ellipse_shadow()
	if model.state == FighterState.State.KO or model.state == FighterState.State.KNOCKDOWN:
		draw_rect(Rect2(-35, -20, 70, 20), color.darkened(0.3))
		draw_circle(Vector2(30 * face, -14), 12, color)
	else:
		var height: float = 48.0 if model.crouching else 84.0
		var bob: float = 2.0 * sin(model.position.x * 0.2) if model.state == FighterState.State.WALK else 0.0
		var body_color: Color = Color.WHITE if model.state == FighterState.State.HITSTUN else color
		draw_rect(Rect2(-14, -height + 25 + bob, 28, height - 40), body_color)
		draw_circle(Vector2(0, -height + 12 + bob), 13, body_color.lightened(0.2))
		draw_rect(Rect2(4 * face - 2, -height + 8 + bob, 4, 4), Color("101c30"))
		draw_line(Vector2(-8, -18), Vector2(-10, -2), color, 8)
		draw_line(Vector2(8, -18), Vector2(10, -2), color, 8)
		var hand := Vector2(23 * face, -height + 39)
		if model.state == FighterState.State.ATTACK:
			var reach: float = 45.0 if model.active() else 22.0
			hand = Vector2(reach * face, -23 if model.attack.hit_level == "low" else -height + 39)
		if model.state == FighterState.State.VICTORY:
			hand = Vector2(22 * face, -100)
		draw_line(Vector2(8 * face, -height + 32), hand, color.lightened(0.2), 8)
		draw_circle(hand, 6, color.lightened(0.3))
		if model.guarding:
			draw_arc(Vector2(10 * face, -height / 2), 28, -PI / 2 if face > 0 else PI / 2, PI / 2 if face > 0 else PI * 1.5, 12, Color("d9f4ff"), 3)
	if model.state == FighterState.State.ATTACK and model.attack.hit_level == "throw":
		# A missed grab must still be distinguishable from a light punch.
		draw_string(ThemeDB.fallback_font, Vector2(-21, -111), "THROW", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color.lightened(0.3))
	if show_boxes:
		draw_rect(Rect2(model.hurtbox().position - model.position, model.hurtbox().size), Color(0.2, 1, 0.4, 0.7), false, 1)
		if model.active():
			var hitbox: Rect2 = model.world_hitbox()
			draw_rect(Rect2(hitbox.position - model.position, hitbox.size), Color(1, 0.25, 0.2, 0.65), false, 2)

func draw_ellipse_shadow() -> void:
	draw_set_transform(Vector2.ZERO, 0, Vector2(1, 0.2))
	draw_circle(Vector2.ZERO, 25, Color(0, 0, 0, 0.4))
	draw_set_transform(Vector2.ZERO)
