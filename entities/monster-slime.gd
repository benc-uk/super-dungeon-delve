extends Monster

func _ready():
	$AnimatedSprite.animation = "slime"
	$Particles2D.modulate = Color("97da3f")
	$SfxDeath.stream = load("res://assets/sfx/squish.wav")
	
	health = 15
	gold = 10
	death_sfx = "3"
	speed = rand_range(20, 60)
	#_velocity = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0))
	_direction = Vector2(rand_range(-1.0, 1.0), rand_range(-1.0, 1.0)).normalized()	