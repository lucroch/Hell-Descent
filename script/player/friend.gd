extends KinematicBody2D

# FRIEND VARIABLES

var accel: float = 0.1
var friction: float = 0.25
var weight: int = Game.gravity
var motion = Vector2.ZERO

var anim: int = 0 setget set_anim
var dir: int = 0 setget set_dir
enum state {Idle, Walking, Jumping, Falling}

onready var sprite = $Sprite

# GAME PHYSICS

func _physics_process(delta) -> void:
	motion.x = lerp(motion.x, 0, friction)
	motion.y += weight
	motion = move_and_slide(motion, Vector2.UP)

# SET DIRECTION

func set_dir(direction) -> void:
	if direction < 0:
		sprite.set_flip_h(true)
	elif direction > 0:
		sprite.set_flip_h(false)

# SET ANIMATION

func set_anim(animation) -> void:
	match animation:
		state.Idle:
			sprite.set_animation("Idle")
		state.Walking:
			sprite.set_animation("Walking")
		state.Jumping:
			sprite.set_animation("Jumping")
		state.Falling:
			sprite.set_animation("Falling")
