extends KinematicBody2D

var time:= 0.0
var rng: = RandomNumberGenerator.new()
var light_old_pos = Vector2(8, 8)

export var base_speed = Vector2(120, 120)
var _velocity: = Vector2.ZERO
var _speed = Vector2.ZERO
var _last_dir: = Vector2.ZERO

func _ready():
	rng.randomize()
	print("DPI: ", OS.get_screen_dpi(OS.get_current_screen()))
	$Camera2D.scale.x = OS.get_screen_dpi(OS.get_current_screen()) / 480
	$Camera2D.scale.y = OS.get_screen_dpi(OS.get_current_screen()) / 480

func _input(event):
	var xzone = get_viewport_rect().size.x / 3
	var yzone = get_viewport_rect().size.y / 3
	if event is InputEventMouseButton:
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
	time += delta
	if time > 500000: time = 0

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
	var direction = get_direction()
	_speed = base_speed
	
	if direction.x < 0: $Sprite.flip_h = true
	if direction.x > 0: $Sprite.flip_h = false
	
	_velocity = move_and_slide(direction * _speed, Vector2.UP, false, 4, 0.78, false)
	
	# light flicker		
	$Light2D.texture_scale = 0.19 + (cos(time * 9) * 0.005)
	$Light2D.energy = 2.8 + (cos(time * 2) * 0.1)
	
func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	
func _on_LightTimer_timeout():
	var light_new_pos = Vector2(rand_range(4, 12), rand_range(4, 12))
	$Light2D/Tween.interpolate_property($Light2D, "position:x", light_old_pos.x, light_new_pos.x, 0.5, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Light2D/Tween.interpolate_property($Light2D, "position:y", light_old_pos.y, light_new_pos.y, 0.5, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Light2D/Tween.start()
	light_old_pos = light_new_pos
