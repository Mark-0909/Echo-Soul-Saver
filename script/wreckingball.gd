extends Area2D

@onready var game_manager: Node = %gameManager

@onready var timer: Timer = $"../gameManager/Timer"


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		if body.has_method("MinusHealth"):
			body.MinusHealth()
			await get_tree().create_timer(0.5).timeout
		
		
