extends CharacterBody2D

const SPEED := 200.0
var spawn_position: Vector2
var key_found: bool = false   # Flag set true when key is picked
var opened_gates := []        # Array to store all gates opened

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	spawn_position = global_position
	add_to_group("player")
	sprite.play("still")  # Start with idle animation

func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO

	# Movement input
	if Input.is_action_pressed("p2_right"):
		direction.x += 1
	if Input.is_action_pressed("p2_left"):
		direction.x -= 1
	if Input.is_action_pressed("p2_down"):
		direction.y += 1
	if Input.is_action_pressed("p2_up"):
		direction.y -= 1

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * SPEED
		move_and_slide()

		if sprite.animation != "walk":
			sprite.play("walk")

		if direction.x != 0:
			sprite.flip_h = direction.x < 0
	else:
		velocity = Vector2.ZERO
		move_and_slide()

		if sprite.animation != "still":
			sprite.play("still")

	# Collision checks
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()

		if collider:
			# Hazards reset player
			if collider.is_in_group("fireball") or collider.is_in_group("spike"):
				_reset_player()

			# Gate interaction
			elif collider.is_in_group("gate"):
				if key_found:
					# Disable gate collider temporarily
					if collider.has_node("CollisionShape2D") and collider not in opened_gates:
						collider.get_node("CollisionShape2D").set_deferred("disabled", true)
						opened_gates.append(collider)  # remember gate
					print("🚪 Gate unlocked, you may pass!")
				else:
					print("🚫 You need a key to pass this gate!")

# Called when player collects a key
func collect_key() -> void:
	key_found = true
	print("🔑 Key collected!")

# Reset player
func _reset_player() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	key_found = false
	print("🔄 Player reset to spawn. Key lost!")
	sprite.play("still")

	# Re-enable all previously opened gates
	for gate in opened_gates:
		if gate.has_node("CollisionShape2D"):
			gate.get_node("CollisionShape2D").set_deferred("disabled", false)
	opened_gates.clear()
