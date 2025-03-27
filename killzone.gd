extends Area2D

@onready var game_manager: Node = %gameManager

@onready var timer: Timer = $"../gameManager/Timer"

func _on_body_entered(body: Node2D) -> void:
	print("You died!")
	timer.start()
	game_manager.timerstarter()
	
	
