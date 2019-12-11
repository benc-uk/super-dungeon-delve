extends KinematicBody2D

var _time:= 0.0
var rng: = RandomNumberGenerator.new()
var _light_old_pos = Vector2(8, 8)
var _velocity: = Vector2.ZERO
var _speed = Vector2.ZERO
var _last_dir: = Vector2(1.0, 0.0)
var _recoil_time = 0.0
var _recoil_dir = Vector2.ZERO

export var base_speed = Vector2(120, 120)
export var light_size = 0.19
export var light_brightness = 2.4
var health = 100
var attack_cooldown = 0.0

const SCENE_WEAPON: = preload("res://actors/Weapon.tscn")

func _ready():
	rng.randomize()
	var zoom_factor = OS.get_screen_dpi(OS.get_current_screen()) / 480.0
	print("zoom_factor: ", zoom_factor)
	$Camera2D.zoom = Vector2(zoom_factor, zoom_factor)

func _input(event):
	var xzone = get_viewport_rect().size.x / 3
	var yzone = get_viewport_rect().size.y / 3

	if event is InputEventMouseButton:
		if event.button_index == 5:
			$Camera2D.zoom = Vector2($Camera2D.zoom.x * 0.9, $Camera2D.zoom.y * 0.9)
		if event.button_index == 4:
			$Camera2D.zoom = Vector2($Camera2D.zoom.x * 1.1, $Camera2D.zoom.y * 1.1)
		
		if get_viewport().get_mouse_position().x > xzone*2:
			Input.action_press("move_right")
		if get_viewport().get_mouse_position().x < xzone:
			Input.action_press("move_left")
		if get_viewport().get_mouse_position().y > yzone*2:
			Input.action_press("move_down")
		if get_viewport().get_mouse_position().y < yzone:
			Input.action_press("move_up")			
			
		if not event.pressed:
			Input.action_release("move_right")
			Input.action_release("move_left")
			Input.action_release("move_up")
			Input.action_release("move_down")
						
func _physics_process(delta: float):
	_time += delta
	attack_cooldown -= delta
	wrapf(_time, 0, 864000)
	
	# Momentum code, not sure I like it
	#if Input.is_action_pressed("move_left"): _speed = base_speed
	#if Input.is_action_pressed("move_right"): _speed = base_speed
	#if Input.is_action_pressed("move_up"): _speed = base_speed
	#if Input.is_action_pressed("move_down"): _speed = base_speed
	#var direction = get_direction()
	#if direction.x == 0 and direction.y == 0: 
	#	direction = _last_dir
	#else:
	#	_last_dir = direction
	#_speed *= 0.8
	#if _speed.x < 0.0001 and _speed.y < 0.0001: _speed = Vector2.ZERO
	
	# No momentum 		
	var direction = _get_direction()
	if _recoil_time > 0.01:
		direction = _recoil_dir
		_recoil_time *= 0.6
		
	#if direction.x != 0 or direction.y != 0: 
	#	_last_dir = direction
	_speed = base_speed
	
	if direction.x != 0 or direction.y != 0:
		_last_dir = direction
		
	$Sprite.flip_h = true if _last_dir.x < 0 else false
	_velocity = direction  * _speed 
	_velocity = move_and_slide(_velocity)
	for i in get_slide_count():
		var collision: = get_slide_collision(i)
		if collision:
			if collision.collider.get_filename() == "res://actors/Monster.tscn":
				_take_damage(collision)
			
	if direction.x > 0 or direction.y > 0 or direction.x < 0 or direction.y < 0:
		$Sprite.play("walk")
	else:
		$Sprite.play("idle")
				
	# light flicker		
	$Light2D.texture_scale = light_size + (cos(_time * 9) * 0.005)
	$Light2D.energy = light_brightness + (cos(_time * 2) * 0.2)


	if Input.is_action_pressed("attack") and attack_cooldown <= 0.001:
		var weapon: = SCENE_WEAPON.instance()
		weapon.get_node("Sprite").flip_h = true if _last_dir.x < 0 else false
		weapon.position.x = 16 * _last_dir.x
		weapon.position.y = 0
		add_child(weapon)
		attack_cooldown = 0.6

func _get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	

func _on_Sprite_frame_changed():
	if $Sprite.animation == "walk":
		$SfxFootstep.volume_db = rng.randf_range(-10.0, 1.0)
		$SfxFootstep.pitch_scale = rng.randf_range(0.7, 1.3)
		$SfxFootstep.play(0.0)


func _on_LightTimer_timeout():
	var light_new_pos = Vector2(rand_range(4, 12), rand_range(4, 12))
	$Light2D/Tween.interpolate_property($Light2D, "position:x", _light_old_pos.x, light_new_pos.x, 0.5, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Light2D/Tween.interpolate_property($Light2D, "position:y", _light_old_pos.y, light_new_pos.y, 0.5, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Light2D/Tween.start()
	_light_old_pos = light_new_pos


func _take_damage(collision: KinematicCollision2D):
	$SfxPain.volume_db = rng.randf_range(-10.0, 1.0)
	$SfxPain.pitch_scale = rng.randf_range(0.7, 1.3)
	$SfxPain.play(0.0)	

	health -= 5 + (randi() % 25)
	if health <= 0:
		get_tree().change_scene("res://GameOver.tscn")	

	_recoil_dir = collision.normal
	_recoil_time = 0.8

	$"/root/Main/HUD/HealthBar".value = health	
