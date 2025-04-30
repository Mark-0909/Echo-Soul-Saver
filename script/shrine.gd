extends Area2D

@onready var wood: CharacterBody2D = $"../../woods/wood5"
@onready var game_manager: Node = %gameManager

var is_activated: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not is_activated:
		if body.get("souls") >= 5:
			print("Enough souls")
			is_activated = true
			
			
			body.Done(true)

			var sfx = body.get_node("ritualsfx")
			sfx.play()

			$AnimatedSprite2D.play("shine")
			await get_tree().create_timer(0.5).timeout

			body.set("souls", 0)

			# Wait for each soul to disperse
			for soul in get_tree().get_nodes_in_group("Soul"):
				if soul.has_method("Disperse"):
					await soul.Disperse()

			
			await get_tree().create_timer(8).timeout
			$"../../CanvasLayer/Ending".visible = true
			get_tree().paused = true
		else:
			print("Not enough souls:", body.get("souls"))
