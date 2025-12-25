extends CharacterBody2D

@export var speed: float = 220.0   # faster than Fireball1
var direction: int = -1            # -1 = left, 1 = right

func _physics_process(delta):
	velocity.x = direction * speed
	move_and_slide()

	# Flip direction when hitting a wall
	if is_on_wall():
		direction *= -1
