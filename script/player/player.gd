extends KinematicBody2D

# PLAYER VARIABLES

var speed: int = 90
var jump: int = 170
var accel: float = 0.1
var friction: float = 0.25
var weight: int = Game.gravity
var motion = Vector2.ZERO
var direction: int = 0
var fall_speed: float = 200

# ANIMATION STATES

var animation
enum anim {Idle, Walking, Jumping, Falling}

# NODES

onready var sprite = $Sprite

func _physics_process(delta) -> void:
	
	# GAME PHYSICS
	
	get_input()
	get_direction()
	get_animation()
	motion = move_and_slide(motion, Vector2.UP)
	
	# MULTIPLAYER PACKETS
	
	P2P._send_packet(P2P.CHANNEL, "all", P2P.SEND.unreliable_no_delay, [
		P2P.TYPE.move,
		self.get_position(),
		animation,
		direction
	])

func get_input() -> void:
	
	# HORIZONTAL MOVEMENT
	
	direction = 0
	if Input.is_action_pressed("right"):
		direction += 1
	if Input.is_action_pressed("left"):
		direction -= 1
	if direction != 0:
		motion.x = lerp(motion.x, direction * speed, accel)
	else:
		motion.x = lerp(motion.x, 0, friction)
		if motion.x<0.00003 and motion.x>-0.00003:
			motion.x = 0
	
	# VERTICAL MOVEMENT
	
	if Input.is_action_just_pressed("up") and is_on_floor():
		motion.y = -jump
	
	var momentum = 0
	if !is_on_floor() and motion.y > 0:
		if Input.is_action_pressed("up"):
			momentum -= 1
		if Input.is_action_pressed("down"):
			momentum += 1
	
	match momentum:
		0:
			motion.y = move_toward(motion.y, fall_speed, weight)
		-1:
			var fall = weight
			if motion.y > 100:
				fall *= 1.5
			else:
				fall *= 0.75
			motion.y = move_toward(motion.y, fall_speed*0.6, fall)
		1:
			motion.y = move_toward(motion.y, fall_speed*1.5, weight*1.5)

# FLIPS CHARACTER

func get_direction() -> void:
	
	if direction < 0:
		sprite.set_flip_h(true)
	elif direction > 0:
		sprite.set_flip_h(false)

# SETS PLAYER CURRENT ANIMATION

func get_animation() -> void:
	
	# GROUND ANIMATION
	
	if is_on_floor():
		if motion.x > 5 or motion.x < -5:
			animation = anim.Walking
		else:
			animation = anim.Idle
	
	# AERIAL ANIMATION
	
	else:
		if motion.y > 0.1:
			animation = anim.Falling
		else:
			animation = anim.Jumping
	
	# GET ANIMATION STATE
	
	match animation:
		anim.Idle:
			sprite.set_animation("Idle")
		anim.Walking:
			sprite.set_animation("Walking")
		anim.Jumping:
			sprite.set_animation("Jumping")
		anim.Falling:
			sprite.set_animation("Falling")
