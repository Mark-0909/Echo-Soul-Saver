extends CharacterBody2D

var life: int = 3
@onready var soul_location: Marker2D = $Marker2D
const SOUL = preload("res://node/soul.tscn")
func _ready() -> void:
	$Sprite2D.flip_h = false
	$Sprite2D.flip_v = false

func LoseLife() -> void:
	life -= 1
	print("Enemy hit! Remaining life:", life)

	if life <= 0:
		var soul = SOUL.instantiate()
		$Sprite2D.play("dead")
		await get_tree().create_timer(0.2).timeout  
		queue_free()
		get_tree().root.add_child(soul)
		soul.global_position = soul_location.global_position

func _on_body_entered(body: Node2D) -> void:
	print("Something touched the enemy:", body.name)
