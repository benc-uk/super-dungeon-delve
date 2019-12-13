extends KinematicBody2D

export var speed = 80
var _velocity = Vector2(0.2, 0.9)
var dead = false

func _ready():
	speed = rand_range(50, 60)
	_velocity = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
	if randf() > 0.5:
		$AnimatedSprite.play("skel")
	else:
		$AnimatedSprite.play("slime")

func _physics_process(delta):
	#if dead: return
	#var player: = $"../Player"
	#_velocity.x = 1.0 if player.position.x > position.x else -1.0
	#_velocity.y = 1.0 if player.position.y > position.y else -1.0
	var collision: = move_and_collide(_velocity * delta * speed)
	if collision:
		_velocity = _velocity.bounce(collision.normal)
		if collision.collider.get_filename() == "res://entities/weapon.tscn":
			#_velocity = _velocity.bounce(collision.position)
			#$AnimatedSprite.modulate = Color("ee1111")
			speed = 200
			$AnimationPlayer.play("death")
			dead = true
			set_collision_mask_bit(1, false)

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "death":
		queue_free()
