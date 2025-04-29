extends Area2D

@onready var wood: CharacterBody2D = $"../../woods/wood5"


var is_activated: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.get("souls") >= 5 and not is_activated:
			print("Enough souls")
			$AnimatedSprite2D.play("shine")
			
			var wood_sprite: AnimatedSprite2D = wood.get_node("AnimatedSprite2D")
			wood_sprite.play("open") 
			
			await get_tree().create_timer(0.7).timeout
			wood.queue_free() 
			body.set("souls", 0)

			# Get all nodes in the "Soul" group and call Disperse() on each
			for soul in get_tree().get_nodes_in_group("Soul"):
				if soul.has_method("Disperse"):
					soul.Disperse()

			is_activated = true
		else:
			print("Not enough souls")
			print(body.get("souls"))
