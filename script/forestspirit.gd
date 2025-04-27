extends CharacterBody2D

var life: int = 3
@onready var soul_location: Marker2D = $Marker2D
const SOUL = preload("res://node/soul.tscn")

@onready var sprite: AnimatedSprite2D = $Sprite2D

var player: Node2D = null  # We will find any node in group "Player"

func _ready() -> void:
	sprite.flip_h = false
	sprite.flip_v = false

func _physics_process(delta: float) -> void:
	if player == null:
		# Find any node that is in group "Player"
		for node in get_tree().get_current_scene().get_children():
			if node.is_in_group("Player"):
				player = node
				break

	if player != null:
		var distance = global_position.distance_to(player.global_position)
		if distance <= 200:
			if player.global_position.x > global_position.x:
				sprite.flip_h = false  # Player is on right
			else:
				sprite.flip_h = true   # Player is on left

func LoseLife() -> void:
	life -= 1
	print("Enemy hit! Remaining life:", life)

	if life <= 0:
		var soul = SOUL.instantiate()
		sprite.play("dead")
		await get_tree().create_timer(0.2).timeout  
		queue_free()
		get_tree().root.add_child(soul)
		soul.global_position = soul_location.global_position
