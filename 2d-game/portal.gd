extends Area2D
## Magic portal at the end of a level. It stays locked (gray, slow) until every
## potion in the level has been collected, then turns purple and spins fast.
## Walking into an open portal fades the screen and loads the next level.
## Author: Mario Cabrera

## The scene to load when the player enters (pick it in the Inspector).
@export_file("*.tscn") var next_level: String = "res://win_screen.tscn"
@export var locked_color: Color = Color(0.5, 0.5, 0.58)
@export var open_color: Color = Color(0.75, 0.35, 1.0)

var is_open := false
var _time := 0.0
var _entering := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	# potions leave the "potions" group as soon as they're picked up
	if not is_open and get_tree().get_nodes_in_group("potions").is_empty():
		_open()
	queue_redraw()


func _open() -> void:
	is_open = true
	# little "pop" so the player notices
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.15)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)
	# if the player is already standing in it, let them through
	for body in get_overlapping_bodies():
		_on_body_entered(body)


func _draw() -> void:
	var c := open_color if is_open else locked_color
	var spin := 3.0 if is_open else 0.6
	var pulse := 0.5 + 0.5 * sin(_time * 3.0)

	# squash circles into a tall oval
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(0.6, 1.0))
	draw_circle(Vector2.ZERO, 95.0 + pulse * 8.0, Color(c, 0.12))   # outer glow
	draw_circle(Vector2.ZERO, 75.0, Color(c.darkened(0.6), 0.9))    # dark inside
	# swirling rings
	for i in 3:
		var r := 25.0 + i * 18.0
		var start := _time * spin * (1.0 + i * 0.5) * (1 if i % 2 == 0 else -1)
		draw_arc(Vector2.ZERO, r, start, start + PI * 1.3, 32, c.lightened(0.2 * i), 6.0)
	draw_arc(Vector2.ZERO, 75.0, 0.0, TAU, 48, c.lightened(0.3), 8.0)  # rim


func _on_body_entered(body: Node) -> void:
	if _entering or body.name != "Player":
		return
	if not is_open:
		var hud := get_tree().get_first_node_in_group("hud")
		if hud:
			hud.call("show_message", "The portal is locked... find all the potions!")
		return
	_enter(body as Node2D)


func _enter(player: Node2D) -> void:
	_entering = true
	if next_level == "":
		push_warning("Portal has no next_level set!")
		return
	player.set_physics_process(false)  # freeze the player

	# black screen that fades in on top of everything
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	var fade := ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade.size = get_viewport().get_visible_rect().size
	layer.add_child(fade)

	var tween := create_tween().set_parallel(true)
	tween.tween_property(player, "modulate:a", 0.0, 0.4)
	tween.tween_property(fade, "color:a", 1.0, 0.7)
	tween.chain().tween_callback(_go_to_next_level)


func _go_to_next_level() -> void:
	get_tree().change_scene_to_file(next_level)
