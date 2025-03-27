extends Node

var score = 0;

@onready var player: CharacterBody2D = $"../Player"

@onready var counter: Label = $"../Player/Counter"




func add_score():
	score += 1
	counter.text = "Coins: " + str(score)
