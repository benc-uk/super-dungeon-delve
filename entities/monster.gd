extends KinematicBody2D
class_name Monster 

export var speed = 0
export var health = 100
export var damage = 5
export var gold = 100
export var factor = 1.0
export var death_sfx = "1"

var _velocity: = Vector2(0.2, 0.9)
var _recoil_countdown = 0.0
var _dead = false
const RECOIL_SPEED = 200
const RECOIL_TIME = 0.15

func _ready():
	pass	

func _physics_process(delta):
	var current_speed = speed
	
	# If recoiling
	if _recoil_countdown >= 0:
		current_speed = RECOIL_SPEED
		_recoil_countdown -= delta
		
	var collision: = move_and_collide(_velocity * delta * current_speed * factor)
	if collision:
		# If hit by weapon
		if collision.collider.get_filename() == "res://entities/weapon.tscn":
			# and *not* recoiling - take damage
			if _recoil_countdown < 0:
				var player: Player = get_node("/root/Main/Player")
				$Particles2D.one_shot = true
				$Particles2D.emitting = true
				$Particles2D.scale = Vector2(0.5, 0.5)
				health -= player.weapon_damage / factor
				
				_velocity = position - player.position 
				_velocity = _velocity.normalized()
				_recoil_countdown = RECOIL_TIME
				
				$SfxHit.pitch_scale = randf() + 0.8
				$SfxHit.play(0.0)
		# Bounce off everything else
		else:
			_velocity = _velocity.bounce(collision.normal)

		if health <= 0 and not _dead:
			_dead = true
			set_collision_mask_bit(1, false)
			set_collision_layer_bit(2, false)
			speed = 0
			$Particles2D.one_shot = true
			$Particles2D.emitting = true
			$Particles2D.scale = Vector2(1.2, 1.2)
			
			# Start death anim
			$AnimationPlayer.play("death")
				
			$SfxDeath.pitch_scale = randf() + 0.5
			$SfxDeath.play(0.0)
			
			globals.player.add_gold(gold * factor)
			globals.kills += 1
			
			# Stop coliding with player
			set_collision_mask_bit(1, false)

# When death anim completes, destroy/free the object
func _on_AnimationPlayer_animation_finished(anim_name):
	pass

func _on_SfxDeath_finished():
	queue_free()		
	