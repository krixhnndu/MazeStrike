extends Area2D

func _ready() -> void:
	add_to_group("gem")  # Optional, helps group all gems
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		print("💎 Gem collected!")
		queue_free()   # ✅ remove gem from the scene
