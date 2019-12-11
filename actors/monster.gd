extends KinematicBody2D

export var speed = 80
var _velocity = Vector2(0.2, 0.9)

func _ready():
	speed = rand_range(50, 80)
	_velocity = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))

func _physics_process(delta):
	#var player: = $"../Player"
	#_velocity.x = 1.0 if player.position.x > position.x else -1.0
	#_velocity.y = 1.0 if player.position.y > position.y else -1.0
	var collision: = move_and_collide(_velocity * delta * speed)
	if collision:
		if collision.collider.get_filename() == "res://actors/Weapon.tscn":
			queue_free()
		_velocity = _velocity.bounce(collision.normal)