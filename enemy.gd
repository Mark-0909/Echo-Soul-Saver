extends CharacterBody2D

var life: int = 3

func _ready() -> void:
	$Sprite2D.flip_h = true
	$Sprite2D.flip_v = true

func LoseLife() -> void:
	life -= 1
	print("Enemy hit! Remaining life:", life)

	if life <= 0:
		queue_free()  # Remove enemy when life reaches 0

func _on_body_entered(body: Node2D) -> void:
	print("Something touched the enemy:", body.name)
