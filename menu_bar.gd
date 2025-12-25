extends Control

func _on_start_pressed() -> void:
	# Load and switch to the "main" scene
	get_tree().change_scene_to_file("res://main.tscn")  

func _on_exit_pressed() -> void:
	# Quit the game
	get_tree().quit()
