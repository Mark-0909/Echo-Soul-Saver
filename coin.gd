extends Area2D

@onready var game_manager: Node = %gameManager

func _on_body_entered(body: Node2D) -> void:
	game_manager.add_score()
	queue_free()
	
	
