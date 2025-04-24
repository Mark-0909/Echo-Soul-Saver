extends Node2D

var initial_position: float  
const BULLET = preload("res://node/bullet.tscn")

@onready var muzzle: Marker2D = $Marker2D
@export var is_player_gun: bool = false  
@onready var enemysprite: AnimatedSprite2D = $"../Sprite2D"
@export var detection_radius: float = 300.0

var player_in_range: bool = false  
var is_shooting: bool = false  

func _ready() -> void:
	initial_position = position.x
	$AnimatedSprite2D.play("steady")
	$AnimatedSprite2D.flip_v = false
	
	await get_tree().process_frame  

	if not is_player_gun:
		check_player_distance()  

func _process(delta: float) -> void:
	if not is_player_gun:
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
			
			look_at(player.global_position)  
			update_gun_orientation()
		else:
			player_in_range = false  
			is_shooting = false  

func update_gun_orientation() -> void:
	rotation_degrees = wrapf(rotation_degrees, 0, 360)  

	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1  
		$AnimatedSprite2D.position.x = initial_position
		enemysprite.flip_h = false
	else:
		scale.y = 1  
		$AnimatedSprite2D.position.x = -initial_position
		enemysprite.flip_h = true

func start_shooting_cycle() -> void:
	is_shooting = true  
	while player_in_range:  
		await shoot_enemy_gun()
		await get_tree().create_timer(2.0).timeout  

	is_shooting = false  

func shoot_enemy_gun() -> void:
	print("Enemy fires!") 
	$AnimatedSprite2D.play("fire")

	shoot_bullet()
	await get_tree().create_timer(0.3).timeout 
	shoot_bullet()
	await get_tree().create_timer(0.3).timeout 
	shoot_bullet()

	await get_tree().create_timer(0.5).timeout  
	$AnimatedSprite2D.play("steady")

func shoot_bullet() -> void:
	var bullet_instance = BULLET.instantiate()
	bullet_instance.is_player_bullet = false
	get_tree().root.add_child(bullet_instance)
	bullet_instance.global_position = muzzle.global_position
	bullet_instance.rotation = rotation
	print("Bullet fired!")  
