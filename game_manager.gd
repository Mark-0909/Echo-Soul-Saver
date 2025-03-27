extends Node

var score = 0;

@onready var player: CharacterBody2D = $"../Player"

@onready var counter: Label = $"../Player/Counter"

func add_score():
	score += 1
	counter.text = "Coins: " + str(score)


@onready var timer: Timer = $Timer

func timerstarter() -> void:
	timer.start()
	
func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
