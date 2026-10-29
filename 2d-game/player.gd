extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -800.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	#Attack
	if Input.is_action_just_pressed("ui_accept"):
		$Wizard.play("attack")

	# Get the input direction and handle the movement
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		$Wizard.flip_h = (direction < 0)
		
		# Flip AttackArea position based on facing direction
		$AttackArea.position.x = -abs($AttackArea.position.x) if direction < 0 else abs($AttackArea.position.x)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Only switch to walk or idle if the wizard is NOT currently attacking
	if $Wizard.animation != "attack" or not $Wizard.is_playing():
		if direction != 0:
			$Wizard.play("walk")
		else:
			$Wizard.play("idle")
			
	move_and_slide()
	
#Fighting goblin triggers only when attacking
func _on_attack_area_body_entered(body: Node2D) -> void:
	# Only deal damage if the wizard is actively playing the attack animation
	if $Wizard.animation == "attack" and $Wizard.is_playing():
		if body.has_method("take_damage"):
			body.take_damage()
	
# Death
func die() -> void:
	get_tree().reload_current_scene()
