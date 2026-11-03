extends Control
## End screen shown after the Level 3 portal. Press Enter/Space to go back to the menu.
## Author: Mario Cabrera

@export_file("*.tscn") var menu_scene: String = "res://menu.tscn"


func _ready() -> void:
	# fade in from black
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.8)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file(menu_scene)
