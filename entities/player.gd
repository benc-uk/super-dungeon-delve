extends KinematicBody2D
class_name Player

var _time:= 0.0
var _light_old_pos = Vector2(8, 8)
var _velocity: = Vector2.ZERO
var _last_dir: = Vector2(1.0, 0.0)
var _attack_dir: = Vector2(1.0, 0.0)
var _recoil_time = 0.0
var _recoil_dir = Vector2.ZERO
var _attack_cooldown = 0.0
var _step = true
var rng: = RandomNumberGenerator.new()

export var base_speed = Vector2(100, 100)
export var light_size = 0.19
export var light_brightness = 2.4
export var health = 100
export var attack_cooldown_time = 0.5
export var weapon_damage = 10.0

const SCENE_WEAPON: = preload("res://entities/weapon.tscn")

func _ready():
	rng.randomize()
	var zoom_factor = OS.get_screen_dpi(OS.get_current_screen()) / 480.0
	#print("zoom_factor: ", zoom_factor)
	$Camera2D.zoom = Vector2(zoom_factor, zoom_factor)
		
#
#
#
func _physics_process(delta: float):
	if Input.is_action_just_pressed("test"):
		pass
		#globals.depth = 1
		#$"/root/Main".next_level()
		
	_time += delta
	_attack_cooldown -= delta
	_recoil_time -= delta
	wrapf(_time, 0, 864000)

	var direction = _get_direction()
		
	$Sprite.flip_h = true if _last_dir.x < 0 else false
	_velocity = direction  * base_speed 
	_velocity = move_and_slide(_velocity)
#	for i in get_slide_count():
#		var collision: = get_slide_collision(i)
#		if collision:
#			# Hit a monster
#			if collision.collider.is_in_group("monsters"):
#				pass
#				#print("player - hit by ", collision.collider.name)
#				#collision.collider.set("time_since_hit_player", 0.0) 
#				#take_damage(collision.normal, collision.collider.damage, collision.collider.factor)
#			# Hit a projectile
#			#if collision.collider.is_in_group("projectiles"):
#			#	take_damage(collision.normal, collision.collider.damage, collision.collider.factor)
#			#	collision.collider.queue_free()

	# Light flicker		
	$Light2D.texture_scale = light_size + (cos(_time * 9) * 0.005)
	$Light2D.energy = light_brightness + (cos(_time * 2) * 0.2)

	# Attack
	if Input.is_action_pressed("attack") and _attack_cooldown <= 0.001:
		_attack()
		
#
#
#
func _get_direction() -> Vector2:
	var new_dir: = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	
	if new_dir.x != 0 or new_dir.y != 0:
		_attack_dir = new_dir	
		
	if _recoil_time > 0:
		$Sprite.play("hit")	
		new_dir = _recoil_dir
		
	if new_dir.x != 0 or new_dir.y != 0:
		_last_dir = new_dir	
		
	if new_dir.x > 0 or new_dir.y > 0 or new_dir.x < 0 or new_dir.y < 0:
		if _recoil_time < 0.01: $Sprite.play("walk")
	else:
		$Sprite.play("idle")
				
	return new_dir

#
# Called when "hit" only bodies
#
func _on_Hitbox_body_entered(body: KinematicBody2D):
	# Calc direction vector between player and "thing"
	var collision_dir: = (position - body.position).normalized()
		
	if body.is_in_group("monsters"):
		# Used by things like goblins
		body.time_since_hit_player = 0.0
		# "bounce" the monster away
		body._direction = (body.position - position).normalized()

	# Now take damage
	globals.player.take_damage(collision_dir, body.damage, body.factor)
	
	# If hit by a projectile, remove it
	if body.is_in_group("projectiles"):
		body.queue_free()
		
#
#
#
func _on_Sprite_frame_changed():
	_step = not _step
	if not _step: return
	if $Sprite.animation == "walk":
		$SfxFootstep.volume_db = rng.randf_range(-20.0, -10.0)
		$SfxFootstep.pitch_scale = rng.randf_range(0.7, 1.3)
		$SfxFootstep.play(0.0)

#
#
#
func _on_LightTimer_timeout():
	var light_new_pos = Vector2(rand_range(4, 12), rand_range(8, 16))
	$Light2D/Tween.interpolate_property($Light2D, "position:x", _light_old_pos.x, light_new_pos.x, 0.5, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Light2D/Tween.interpolate_property($Light2D, "position:y", _light_old_pos.y, light_new_pos.y, 0.5, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Light2D/Tween.start()
	_light_old_pos = light_new_pos

#
#
#
func take_damage(collision_dir: Vector2, damage: float, factor: float):
	if _recoil_time > 0:
		return
	
	$SfxPain.volume_db = rng.randf_range(-10.0, 1.0)
	$SfxPain.pitch_scale = rng.randf_range(0.7, 1.3)
	$SfxPain.play(0.0)	

	var actual_damage = floor( (damage + (randi() % 5)) * factor)
	health -= actual_damage
	if health <= 0:
		get_tree().change_scene("res://core/game-over.tscn")	

	_recoil_dir = collision_dir
	_recoil_time = 0.2

	$Sprite.play("hit")
	$"/root/Main/HUD/HealthBar".value = health	
	$"/root/Main/HUD/HealthBar/AnimationPlayer".play("blink")

#
#
#
func heal(ammount: int):
	health = min(health + ammount, 100)
	$"/root/Main/HUD/HealthBar".value = health	
	$"/root/Main/HUD/HealthBar".theme
	$"/root/Main/HUD/HealthBar/AnimationPlayer".play("blink")
	
#
#
#
func add_gold(extragold: int):
	globals.gold += extragold
	$"/root/Main/HUD/GoldLabel".text = str(floor(globals.gold))
	$"/root/Main/HUD/GoldLabel/AnimationPlayer".play("blink")

#
#
#
func _attack():
	var weapon: = SCENE_WEAPON.instance()
	weapon.add_to_group("weapons")
	
	$SfxSwipe.pitch_scale = rng.randf_range(0.9, 1.8)
	$SfxSwipe.play(0.0)
	
	if _attack_dir.x > 0:
		weapon.rot = 90
		weapon.position.x = 8
		weapon.position.y = 16
	elif _attack_dir.x < 0:
		weapon.rot = -90
		weapon.position.x = 8
		weapon.position.y = 16
	elif _attack_dir.y > 0:
		weapon.rot = 180
		weapon.position.x = 8
		weapon.position.y = 16
		weapon.z_index = 11
	elif _attack_dir.y < 0:
		weapon.rot = 0
		weapon.position.x = 8
		weapon.position.y = 12

	add_child(weapon)
	_attack_cooldown = attack_cooldown_time


		
#
# **** Attempt at mobile touch screen controls removed for now ****
#
#func _input(event):
#	var xzone = get_viewport_rect().size.x / 3
#	var yzone = get_viewport_rect().size.y / 3
#
#	if event is InputEventMouseButton:
#		if event.button_index == 5:
#			$Camera2D.zoom = Vector2($Camera2D.zoom.x * 0.9, $Camera2D.zoom.y * 0.9)
#		if event.button_index == 4:
#			$Camera2D.zoom = Vector2($Camera2D.zoom.x * 1.1, $Camera2D.zoom.y * 1.1)
#
#		if get_viewport().get_mouse_position().x > xzone*2:
#			Input.action_press("move_right")
#		if get_viewport().get_mouse_position().x < xzone:
#			Input.action_press("move_left")
#		if get_viewport().get_mouse_position().y > yzone*2:
#			Input.action_press("move_down")
#		if get_viewport().get_mouse_position().y < yzone:
#			Input.action_press("move_up")			
#
#		if not event.pressed:
#			Input.action_release("move_right")
#			Input.action_release("move_left")
#			Input.action_release("move_up")
#			Input.action_release("move_down")	

