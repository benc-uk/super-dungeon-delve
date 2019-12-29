extends KinematicBody2D
class_name Monster 

export var speed = 0
export var health = 100
export var damage = 5
export var gold = 100
export var factor = 1.0
export var death_sfx = "1"

var _velocity: = Vector2.ZERO
var _direction: = Vector2.ZERO
var _recoil_countdown = 0.0
var time_since_hit_player = 2000.0
var _dead = false
const RECOIL_SPEED = 200
const RECOIL_TIME = 0.15

func _ready():
	pass	

func _physics_process(delta):
	#if _dead: return
	
	time_since_hit_player += delta
	var current_speed = speed
	
	# If recoiling
	if _recoil_countdown >= 0:
		current_speed = RECOIL_SPEED
		_recoil_countdown -= delta
		
	#var collision: = move_and_collide(_velocity * delta * current_speed * factor)
	_velocity = _direction * current_speed * factor
	_velocity = move_and_slide(_velocity)
	for i in get_slide_count():
		var collision: = get_slide_collision(i)
		if collision:
			_direction = _direction.bounce(collision.normal)

	if health <= 0 and not _dead:
		# Disable effects and hitboxes
		_dead = true
		set_collision_mask_bit(1, false)
		set_collision_layer_bit(2, false)
		$Hitbox/CollisionShape2D.disabled = true		
		speed = 0
		
		# Show hit particle effect
		$Particles2D.one_shot = true
		$Particles2D.emitting = true
		$Particles2D.scale = Vector2(1.2, 1.2)
		
		# Start death anim
		$AnimationPlayer.play("death")
		# Play death sound
		$SfxDeath.pitch_scale = randf() + 0.5
		$SfxDeath.play(0.0)
		
		# Notch up score
		globals.player.add_gold(gold * factor)
		globals.kills += 1

#
# Finally remove when death sfx is done
#
func _on_SfxDeath_finished():
	queue_free()		
	
#
#
#
func _on_Hitbox_body_entered(body):
	# When hit by weapon
	if body.name == "Weapon":
		# and *not* recoiling - take damage
		if _recoil_countdown < 0:
			$Particles2D.one_shot = true
			$Particles2D.emitting = true
			$Particles2D.scale = Vector2(0.5, 0.5)
			health -= globals.player.weapon_damage / factor

			_direction = position - globals.player.position 
			_direction = _direction.normalized()
			_recoil_countdown = RECOIL_TIME

			$SfxHit.pitch_scale = randf() + 0.8
			$SfxHit.play(0.0)
