extends CharacterBody2D

const SPEED := 200.0
var spawn_position: Vector2
var key_found: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	spawn_position = global_position
	add_to_group("player")
	sprite.play("still")

func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
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
					if collider.has_node("CollisionShape2D"):
						collider.get_node("CollisionShape2D").set_deferred("disabled", true)
					print("🚪 Gate unlocked, you may pass!")
					# Optionally consume the key: key_found = false
				else:
					print("🚫 You need a key to pass this gate!")

# Called when the player collects a key
func collect_key() -> void:
	key_found = true
	print("🔑 Key collected!")

# Reset Player function
func _reset_player() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	key_found = false
	print("🔄 Player reset to spawn. Key lost!")
	sprite.play("still")

# Win condition: called when player enters treasure Area2D
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == self:
		print("Main player has found the treasure and game over")
