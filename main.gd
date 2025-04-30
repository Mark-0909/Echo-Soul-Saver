extends Node2D

func _on_pause_pressed() -> void:
	var pause_menu = $"CanvasLayer/PauseMenu"  # Adjust if node name differs

	if not get_tree().paused:
		get_tree().paused = true
		pause_menu.visible = true
	else:
		get_tree().paused = false
		pause_menu.visible = false
