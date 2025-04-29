extends Control

func _ready() -> void:
	pass
func _on_start_pressed() -> void:
	# Replace with the actual path to your main scene
	get_tree().change_scene_to_file("res://main.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
