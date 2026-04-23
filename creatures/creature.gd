class_name Creature extends CharacterBody2D

@onready var hit_area: Area2D = $HitArea
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_wall_right: RayCast2D = $RayWallRight
@onready var ray_wall_left: RayCast2D = $RayWallLeft

const PLAYER_JUMP_DISTANCE = 8

enum Type { SIMPLE, FOLLOW, FLY }

@export var move_speed: float = 80.0
@export var jump_velocity: float = -240.0
@export var type: Type = Type.SIMPLE
@export var follow_player_min_distance: float = 80.80
@export var start_flipped: bool = false

var flying: bool = false
var follow_player: bool = false
var last_direction: float = 1.0
var start_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	if start_flipped:
		animated_sprite.flip_h = true
		last_direction = -1.0
	start_position = global_position
	match (type):
		Type.SIMPLE:
			follow_player = false
			flying = false
		Type.FOLLOW:
			follow_player = true
			flying = false
		Type.FLY:
			follow_player = false
			flying = true
			animated_sprite.play("run")

func _physics_process(delta: float) -> void:
	if not flying:
		ground_movement(delta)
	else:
		fly_movement(delta)

func fly_movement(_delta: float) -> void:
	var direction := 0.0
	if last_direction > 0:
		if ray_wall_right.is_colliding():
			last_direction = -1
	else:
		if ray_wall_left.is_colliding():
			last_direction = 1
	direction = last_direction

	velocity.x = direction * move_speed
	
	if velocity.x >= 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
	
	move_and_slide()

func ground_movement(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction := 0.0
	if follow_player:
		var distance: float = INF
		if GameManager.player:
			distance = GameManager.player.global_position.x - global_position.x
		var ab_distance = abs(distance)
		if ab_distance <= follow_player_min_distance:
			direction = sign(distance)
		# Handle jump.
		if is_on_floor():
			var has_not_ground: bool = not ray_cast_right.is_colliding() or not ray_cast_left.is_colliding()
			var has_wall: bool = ray_wall_left.is_colliding() or ray_wall_right.is_colliding()
			if ab_distance < 20.0 or has_wall or has_not_ground:
				velocity.y = jump_velocity
	else:
		if last_direction > 0:
			if not ray_cast_right.is_colliding() or ray_wall_right.is_colliding():
				last_direction = -1
		else:
			if not ray_cast_left.is_colliding() or ray_wall_left.is_colliding():
				last_direction = 1
		direction = last_direction
	if direction != 0.0:
		velocity.x = direction * move_speed
		if velocity.y == 0.0:
			animated_sprite.play("run")
	else:
		if velocity.y == 0.0:
			animated_sprite.play("idle")
		velocity.x = move_toward(velocity.x, 0, move_speed)
		
	if velocity.x >= 0:
		animated_sprite.flip_h = false
	else:
		animated_sprite.flip_h = true
	
	move_and_slide()

func knockout(source: Node2D = null) -> void:
	GameManager.creature_knockout(self, source)

func _on_hit_area_body_entered(body: Node2D) -> void:
	if body is Player:
		# All this was needed because it seems that sometimes it compares values after
		# 	the frame was processed, with new velocity and position
		var distance: float = global_position.y - body.global_position.y
		var distance_pass: bool = distance > PLAYER_JUMP_DISTANCE
		var position_pass: bool = body.global_position.y < global_position.y
		var velocity_pass: bool = body.velocity.y > 0
		var previous_position_pass: bool = body.previous_position.y < global_position.y
		var previous_velocity_pass: bool = body.previous_velocity.y > 0
		var previous_distance: float = global_position.y - body.previous_position.y
		var previous_distance_pass: bool = previous_distance > PLAYER_JUMP_DISTANCE
		var current_pass: bool = distance_pass or position_pass or velocity_pass
		var previous_pass: bool = previous_distance_pass or previous_position_pass or previous_velocity_pass
		var was_creature_hit: bool = current_pass or (velocity.y < 0 and previous_pass)
		if was_creature_hit:
			body.knocked_out_creature()
			knockout()
		else:
			body.on_hit(self)
