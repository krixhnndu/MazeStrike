extends Area2D

func _ready() -> void:
	add_to_group("treasure")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.name == "CharacterBody2D":
			print("player 1 got the tressure and game over")
		elif body.name == "AIPlayer":
			print("player 2 got the tressure and game over")
		else:
			print("Some player got the tressure")
		body.queue_free()
		get_tree().paused = true
