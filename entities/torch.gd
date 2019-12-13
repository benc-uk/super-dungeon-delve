extends Node2D

func _ready():
	# Stop all torches moving in sync
	$AnimatedSprite.frame = randi() % 4
	$AnimatedSprite.speed_scale = rand_range(0.8, 3)