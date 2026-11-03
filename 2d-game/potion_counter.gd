extends CanvasLayer
## On-screen potion counter (HUD). Finds every potion in the level by itself,
## shows "Potions: X / Y", and pops up short hint messages for the player.
## Drop one copy into any level scene - no setup needed.
## Author: Mario Cabrera

signal all_collected

var total := 0
var collected := 0
var _hint_tween: Tween

@onready var counter: Label = $Counter
@onready var hint: Label = $Hint


func _ready() -> void:
	hint.modulate.a = 0.0
	# wait one frame so every potion in the level is loaded before counting
	_count_potions.call_deferred()


func _count_potions() -> void:
	var potions := get_tree().get_nodes_in_group("potions")
	total = potions.size()
	for p in potions:
		p.connect("collected", _on_potion_collected)
	_update_counter()
	if total > 0:
		show_message("Collect all %d potions to open the portal!" % total, 4.0)


func _on_potion_collected(_potion_name: String, _collector: Node) -> void:
	collected += 1
	_update_counter()
	_bounce_counter()
	if collected >= total:
		show_message("All potions found! The portal is open!")
		all_collected.emit()
	else:
		show_message("%d to go!" % (total - collected), 1.5)


func _update_counter() -> void:
	counter.text = "Potions: %d / %d" % [collected, total]
	if total > 0 and collected >= total:
		counter.modulate = Color(0.6, 1.0, 0.6)  # turns green when done


func _bounce_counter() -> void:
	counter.pivot_offset = counter.size / 2.0
	var tween := create_tween()
	tween.tween_property(counter, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(counter, "scale", Vector2.ONE, 0.15)


## Shows a message near the top of the screen, then fades it out.
## Other scripts (like the portal) can call this too.
func show_message(text: String, seconds: float = 2.5) -> void:
	hint.text = text
	hint.modulate.a = 1.0
	if _hint_tween:
		_hint_tween.kill()
	_hint_tween = create_tween()
	_hint_tween.tween_interval(seconds)
	_hint_tween.tween_property(hint, "modulate:a", 0.0, 0.5)
