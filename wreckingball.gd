extends Area2D

@onready var game_manager: Node = %gameManager
@onready var timer: Timer = $"../../gameManager/Timer"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): 
		print("You died!")
		timer.start()
		game_manager._on_timer_timeout()
		
