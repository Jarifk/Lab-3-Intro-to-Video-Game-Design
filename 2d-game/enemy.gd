extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var direction = 1 #1 is right, -1 is left
var is_dead = false

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

# Turn around at walls
	if is_on_wall():
		direction *= -1
#Move
	velocity.x = direction * SPEED
	$Goblin.flip_h = (direction < 0)
	$Goblin.play("goblinwalk")
	
	move_and_slide()

#When Wizard hits Goblin	
func take_damage() -> void:
	if is_dead:
		return
		
	is_dead = true
	velocity = Vector2.ZERO
	$Goblin.play("goblindie")
	
	#Won't kill wizard after it dies
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
	#	velocity.x = direction * SPEED
	#else:
	#	velocity.x = move_toward(velocity.x, 0, SPEED)
