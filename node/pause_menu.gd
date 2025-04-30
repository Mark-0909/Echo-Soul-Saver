extends Control

func _ready() -> void:
	pass

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false  # Hides the pause menu

func _on_exitpressed() -> void:
	get_tree().quit()
