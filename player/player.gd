class_name Player extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 210.0
const JUMP_VELOCITY = 200.0
const MAX_JUMP_TIME = 0.5
const COYOTE_TIME = 0.333
const CREATURE_IMPULSE = -333.3

var is_jumping: bool = false
var max_jump_time: float = 0
var can_coyote_jump: bool = false
var cancel_coyote_time: float = 0
var is_knocked_out: bool = false

func on_hit(source: Node2D) -> void:
	collision_layer = 0
	collision_mask = 0
	velocity.y = -JUMP_VELOCITY * 1.5
	animated_sprite.play("hurt")
	is_knocked_out = true
	GameManager.player_knockout(self, source)

func knocked_out_creature() -> void:
	if velocity.y > 0:
		velocity.y = -JUMP_VELOCITY * 1.8
	else:
		velocity.y -= JUMP_VELOCITY * 0.9

func _ready() -> void:
	GameManager.set_player(self)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		if Time.get_ticks_msec() > cancel_coyote_time:
			can_coyote_jump = false
		if velocity.y > 0:
			if not is_knocked_out:
				animated_sprite.play("fall")
		else:
			if not is_knocked_out:
				animated_sprite.play("jump")
	else:
		can_coyote_jump = true
		cancel_coyote_time = Time.get_ticks_msec() + COYOTE_TIME * 1000

	# Handle jump.
	if not is_knocked_out:
		if Input.is_action_just_pressed("jump") and can_coyote_jump:
			is_jumping = true
			max_jump_time = Time.get_ticks_msec() + MAX_JUMP_TIME * 1000
			if velocity.y <= 0:
				velocity.y -= JUMP_VELOCITY
			else:
				velocity.y = -JUMP_VELOCITY
		if Input.is_action_pressed("jump") and is_jumping:
			velocity.y += delta * (-JUMP_VELOCITY) * 2.4
			if Time.get_ticks_msec() > max_jump_time:
				is_jumping = false
			

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := 0.0
	if not is_knocked_out:
		direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		if velocity.y == 0:
			if not is_knocked_out:
				animated_sprite.play("run")
		if direction >= 0:
			animated_sprite.flip_h = false
		else:
			animated_sprite.flip_h = true
	else:
		if velocity.y == 0:
			if not is_knocked_out:
				animated_sprite.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
