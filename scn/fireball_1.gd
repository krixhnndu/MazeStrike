extends CharacterBody2D

const SPEED := 200.0
var spawn_position: Vector2
var keys_collected := {}   # Tracks collected keys
var path: Array = []
var path_index: int = 0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var treasure: Node2D
@export var key_nodes: Array        # [Key1, Key2]
@export var door_node: Node2D

var astar := AStar2D.new()
var tile_size := 64
var grid_width := 10
var grid_height := 10

func _ready():
	spawn_position = global_position
	add_to_group("player")
	sprite.play("still")
	keys_collected.clear()
	_build_astar_grid()
	_calculate_path_to_next_target()

func _physics_process(_delta):
	if path.is_empty() or path_index >= path.size():
		_calculate_path_to_next_target()
		if path.is_empty():
			return

	_move_along_path(_delta)
	_handle_collisions()

# Calculate path to next key or treasure
func _calculate_path_to_next_target():
	var target_node: Node2D = null
	for key in key_nodes:
		if not keys_collected.has(key.name):
			target_node = key
			break
	if not target_node and treasure:
		target_node = treasure

	if not target_node:
		path.clear()
		return

	var start_id = astar.get_closest_point(global_position, true)
	var goal_id = astar.get_closest_point(target_node.global_position, true)

	if start_id != -1 and goal_id != -1:
		path = astar.get_point_path(start_id, goal_id)
		path_index = 0

# Move step by step along the A* path
func _move_along_path(_delta):
	if path_index >= path.size():
		velocity = Vector2.ZERO
		if sprite.animation != "still":
			sprite.play("still")
		return

	var target = path[path_index]
	var direction = (target - global_position).normalized()
	velocity = direction * SPEED
	move_and_slide()

	if velocity.length() > 0:
		if sprite.animation != "walk":
			sprite.play("walk")
		if direction.x != 0:
			sprite.flip_h = direction.x < 0
	else:
		if sprite.animation != "still":
			sprite.play("still")

	if global_position.distance_to(target) < 5:
		path_index += 1

# Handle collisions with obstacles, keys, and door
func _handle_collisions():
	# Check for spikes/fireballs
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and (collider.name.begins_with("fireball") or collider.name.begins_with("spike") or collider.name.begins_with("spikes")):
			_reset_player()
			return

	# Collect keys by proximity
	for key in key_nodes:
		if not keys_collected.has(key.name) and global_position.distance_to(key.global_position) < 16:
			keys_collected[key.name] = true
			print("🔑 Collected: ", key.name)
			_calculate_path_to_next_target()
			break

	# Open door if all keys collected
	if door_node and keys_collected.size() == key_nodes.size():
		if global_position.distance_to(door_node.global_position) < 16:
			if door_node.has_node("CollisionShape2D"):
				door_node.get_node("CollisionShape2D").set_deferred("disabled", true)
			print("🚪 Door unlocked!")

# Reset AI to spawn
func _reset_player():
	global_position = spawn_position
	velocity = Vector2.ZERO
	path.clear()
	path_index = 0
	print("🔄 AI reset")
	sprite.play("still")
	keys_collected.clear()
	_calculate_path_to_next_target()

# Build A* grid avoiding obstacles
func _build_astar_grid():
	astar.clear()
	var id := 0

	for x in range(grid_width):
		for y in range(grid_height):
			var pos = Vector2(x * tile_size, y * tile_size)
			var free_space := true

			for node in get_tree().get_nodes_in_group(""):
				if node.name.begins_with("fireball") or node.name.begins_with("spike") or node.name.begins_with("spikes"):
					if node.global_position.distance_to(pos) < tile_size / 2:
						free_space = false
						break

			if free_space:
				astar.add_point(id, pos)
				id += 1

	# Add spawn, keys, treasure explicitly
	var special_points := [spawn_position]
	for key in key_nodes:
		special_points.append(key.global_position)
	if treasure:
		special_points.append(treasure.global_position)

	for sp in special_points:
		astar.add_point(id, sp)
		for other_id in astar.get_point_ids():
			var pos_j = astar.get_point_position(other_id)
			if sp.distance_to(pos_j) <= tile_size + 1:
				astar.connect_points(id, other_id)
		id += 1

	# Connect nearby grid points
	for i in astar.get_point_ids():
		var pos_i = astar.get_point_position(i)
		for j in astar.get_point_ids():
			if i == j:
				continue
			var pos_j = astar.get_point_position(j)
			if pos_i.distance_to(pos_j) <= tile_size + 1:
				astar.connect_points(i, j)
