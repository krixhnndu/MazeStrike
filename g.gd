extends StaticBody2D

func open_gate() -> void:
	var shape = $CollisionShape2D
	if shape:
		shape.set_deferred("disabled", true)  # disable collider
