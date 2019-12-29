extends KinematicBody2D

export var speed: float
export var direction: Vector2
export var damage = 5
export var factor = 1.0
#var _velocity: = Vector2.ZERO

func _ready():
	speed = 60.0 + rand_range(0, 50)
	#direction = Vector2(0.0, 1.0)
	#direction = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)).normalized()
	direction = ($"/root/Main/Player/CollisionShape2D".global_transform.get_origin() - position).normalized()
	$AnimationPlayer.playback_speed = (speed / 110.0) * 2.0
	$AnimationPlayer.play("spin")
	
func _physics_process(delta):
	var _velocity = direction * speed
	var collision = move_and_collide(_velocity * delta)
	if collision: 
		queue_free()