extends Area2D

@onready var game_manager: Node = %gameManager
@onready var timer: Timer = $"../../gameManager/Timer"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.get("is_ghost") == false: 
		if body.has_method("MinusHealth"):
			body.MinusHealth()
			body.apply_knockback(global_position)

	elif body.is_in_group("Player") and body.get("is_ghost") == true:
		pass 
		
		
