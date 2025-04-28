extends CharacterBody2D

var life: int = 3

@onready var soul_location: Marker2D = $PlusHeartLocation
@onready var bulletlocation: Marker2D = $Bulletlocation
@onready var enemysprite: AnimatedSprite2D = $Sprite2D

const BULLET = preload("res://node/bullet.tscn")
const PLUS_LIFE = preload("res://node/plus_life.tscn")

@export var detection_radius: float = 300.0

var player_in_range: bool = false  
var is_shooting: bool = false  

func _ready() -> void:
	enemysprite.flip_h = false
	enemysprite.flip_v = false

func LoseLife() -> void:
	life -= 1
	print("Enemy hit! Remaining life:", life)
	
	enemysprite.play("hurt")
	await get_tree().create_timer(0.5).timeout
	enemysprite.play("default")

	if life <= 0:
		enemysprite.play("dead")
		await get_tree().create_timer(0.5).timeout  

		var heart = PLUS_LIFE.instantiate()
		get_tree().root.add_child(heart)
		heart.global_position = soul_location.global_position

		queue_free()

func _process(delta: float) -> void:
	check_player_distance()

func check_player_distance() -> void:
	var player = get_tree().get_first_node_in_group("Player")  
	if player:
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if distance_to_player <= detection_radius:
			if not player_in_range:  
				player_in_range = true  
				if not is_shooting:
					start_shooting_cycle()
			
			bulletlocation.look_at(player.global_position)
			update_gun_orientation()
		else:
			player_in_range = false  
			is_shooting = false  

func update_gun_orientation() -> void:
	var gun_angle = wrapf(bulletlocation.rotation_degrees, 0, 360)

	if gun_angle > 90 and gun_angle < 270:
		enemysprite.flip_h = false
	else:
		enemysprite.flip_h = true

func start_shooting_cycle() -> void:
	is_shooting = true  
	while player_in_range:  
		await shoot_enemy_gun()
		await get_tree().create_timer(2.0).timeout  

	is_shooting = false  

func shoot_enemy_gun() -> void:
	print("Enemy fires!")
	shoot_bullet()
	await get_tree().create_timer(0.3).timeout
	# Uncomment if you want multiple shots
	#shoot_bullet()
	#await get_tree().create_timer(0.3).timeout
	#shoot_bullet()

func shoot_bullet() -> void:
	enemysprite.play("attack")
	await get_tree().create_timer(0.3).timeout

	var bullet_instance = BULLET.instantiate()
	bullet_instance.is_player_bullet = false
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_position = bulletlocation.global_position
	bullet_instance.rotation = bulletlocation.rotation

	print("Bullet fired!")  

	enemysprite.play("default")
