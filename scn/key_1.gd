extends Area2D

@export var min_distance_from_player: float = 64.0   # avoid spawning too close to player
@export var auto_move_interval: float = 20.0         # seconds between automatic moves

var spawn_points: Array[Vector2] = []
var last_index: int = -1

func _ready() -> void:
	randomize()
	add_to_group("key")
	connect("body_entered", Callable(self, "_on_body_entered"))
	_collect_spawn_points()

	# Timer for auto movement
	var timer := Timer.new()
	timer.wait_time = auto_move_interval
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	timer.connect("timeout", Callable(self, "_auto_teleport"))

func _collect_spawn_points() -> void:
	for n in get_tree().get_nodes_in_group("key_spawn"):
		if n is Node2D:
			spawn_points.append(n.global_position)

	if spawn_points.is_empty():
		for c in get_children():
			if c is Node2D:
				spawn_points.append(c.global_position)

	if spawn_points.is_empty():
		spawn_points.append(global_position)
		push_warning("No key spawn points found. Add Marker2D nodes to group 'key_spawn'.")

# ✅ When player collides with the key
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") or body.is_in_group("player2"):
		if body.has_method("collect_key"):
			body.collect_key()   # tell player to set key_found = true
		# Teleport key away instantly
		monitoring = false
		call_deferred("_teleport_away", body.global_position)

# ✅ Teleport key to a new valid spawn
func _teleport_away(player_pos: Vector2) -> void:
	var idx: int = _pick_new_index(player_pos)
	global_position = spawn_points[idx]
	last_index = idx
	print("✨ Key teleported to new location.")
	await get_tree().process_frame
	monitoring = true

func _pick_new_index(player_pos: Vector2) -> int:
	if spawn_points.size() == 1:
		return 0

	var candidates: Array[int] = []
	for i in range(spawn_points.size()):
		if i != last_index and spawn_points[i].distance_to(player_pos) >= min_distance_from_player:
			candidates.append(i)

	if candidates.is_empty():
		for i in range(spawn_points.size()):
			if i != last_index:
				candidates.append(i)

	return candidates[randi() % candidates.size()]

# ⏱️ Auto teleport every 20s even if not collected
func _auto_teleport() -> void:
	if spawn_points.is_empty():
		return
	var idx := randi() % spawn_points.size()
	while idx == last_index and spawn_points.size() > 1:
		idx = randi() % spawn_points.size()
	global_position = spawn_points[idx]
	last_index = idx
	print("⏱️ Key moved automatically after 20s.")
