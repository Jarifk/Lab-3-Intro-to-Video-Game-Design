extends Area2D
## A magical potion that floats and glows. The player collects it by touching it.
## One scene, three looks: pick the texture and glow color for each copy in the Inspector.
## Author: Mario Cabrera

signal collected(potion_name: String, collector: Node)

@export var potion_name: String = "Health Potion"
@export var texture: Texture2D
@export var glow_color: Color = Color(1.0, 0.3, 0.3)
@export var float_height: float = 6.0   # how far it bobs (pixels)
@export var float_speed: float = 2.5    # how fast it bobs

var _time := 0.0
var _start_y := 0.0
var _taken := false

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_start_y = position.y
	_time = randf() * TAU  # so potions don't all bob in sync
	if texture:
		sprite.texture = texture
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if _taken:
		return
	_time += delta
	position.y = _start_y + sin(_time * float_speed) * float_height
	queue_redraw()


func _draw() -> void:
	# pulsing magic glow behind the bottle
	var pulse := 0.5 + 0.5 * sin(_time * 4.0)
	var c := glow_color
	draw_circle(Vector2.ZERO, 30.0 + pulse * 6.0, Color(c.r, c.g, c.b, 0.15))
	draw_circle(Vector2.ZERO, 20.0, Color(c.r, c.g, c.b, 0.25))


func _on_body_entered(body: Node) -> void:
	if _taken or not body is CharacterBody2D:
		return  # only the player (not the falling robot) can collect
	_taken = true
	collected.emit(potion_name, body)
	print(potion_name, " collected by ", body.name)
	set_deferred("monitoring", false)

	# pop: grow, rise, fade out, then disappear
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.8, 1.8), 0.3)
	tween.tween_property(self, "position:y", position.y - 30.0, 0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(queue_free)
