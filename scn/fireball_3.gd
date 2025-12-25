extends CharacterBody2D

@export var speed: float = 200.0   # movement speed

# Initial diagonal direction (normalized)
var direction: Vector2 = Vector2(1, 1).normalized()

func _physics_process(delta: float) -> void:
	# Set velocity based on direction
	velocity = direction * speed
	
	# Move the fireball
	move_and_slide()
	
	# Bounce on vertical walls (floor/ceiling)
	if is_on_floor() or is_on_ceiling():
		direction.y *= -1
	
	# Bounce on horizontal walls
	if is_on_wall():
		direction.x *= -1
