extends Monster

var _base_speed: = 0.0
const RUN_AWAY_TIME = 0.7

func _ready():
	$AnimatedSprite.animation = "goblin"
	health = 18
	gold = 20
	speed = 20.0 + randf() * 30.0
	_base_speed = speed
	$Particles2D.modulate = Color("3d734f")
	$SfxDeath.stream = load("res://assets/sfx/death.wav")

func _physics_process(delta):
	if _recoil_countdown <= 0:
		# Vector to player
		var los_ray: Vector2 = $"/root/Main/Player/CollisionShape2D".global_transform.get_origin() - $"CollisionShape2D".global_transform.get_origin()
		if los_ray.length() < 200:
			$RayCast2D.cast_to = los_ray
			# If ray collides means no LOS, so stand still
			if $RayCast2D.is_colliding():
				_direction = Vector2.ZERO
				return
		else:
			# If too far way, stand still
			_direction = Vector2.ZERO
			return
		
		# If haven't hit the player recently, move toward them
		if time_since_hit_player > RUN_AWAY_TIME:
			_direction = $"/root/Main/Player/CollisionShape2D".global_transform.get_origin() - $"CollisionShape2D".global_transform.get_origin()
			speed = _base_speed
		else:
			# Else move in opposite direction fast
			_direction =  $"CollisionShape2D".global_transform.get_origin() - $"/root/Main/Player/CollisionShape2D".global_transform.get_origin() 
			speed = _base_speed * 2
			
		_direction = _direction.normalized()
