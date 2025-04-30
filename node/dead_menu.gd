extends Control

@onready var player: CharacterBody2D = $"../../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_exitpressed() -> void:
	get_tree().quit()


func _on_revive_pressed() -> void:
	var checkpoint = %gameManager.get("checkpoint")
	if checkpoint != null:
		%gameManager.checkpoint = checkpoint  # Store for player to use
		get_tree().paused = false  # Unpause the game
		$"." .visible = false  # Hide the pause/revive menu
		var player = get_node_or_null("/root/main/Player")  # Safely get player
		if player:
			player.reviving = true
			print("Reviving at checkpoint: ", checkpoint)
		else:
			print("Player not found!")
