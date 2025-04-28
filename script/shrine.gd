extends Area2D

@onready var wood: CharacterBody2D = $"../wood"
@onready var wood_sprite: AnimatedSprite2D = $"../wood/AnimatedSprite2D"

var is_activated: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.get("souls") == 5 and not is_activated:
			print("Enough souls")
			$AnimatedSprite2D.play("shine")
			wood_sprite.play("open") # Play animation on the AnimatedSprite2D
			await get_tree().create_timer(0.7).timeout
			wood.queue_free() 
			body.set("souls", 0)

			is_activated = true
		else:
			print("Not enough souls")
