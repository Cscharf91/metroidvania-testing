class_name EnemyMovement
extends Node2D

@export var patrol_move_speed: float = 100.0
@export var pursue_move_speed: float = 135.0
@export var ledge_ray_cast: RayCast2D
@export var orientation: EnemyOrientation
@export var player_detection_area: PlayerDetectionArea

@onready var enemy = owner as CharacterBody2D

var facing_dir: float

func _ready() -> void:
	facing_dir = orientation.default_sprite_dir

func move(new_velocity: Vector2) -> void:
	enemy.velocity = lerp(enemy.velocity, new_velocity, 0.2)
	enemy.move_and_slide()

func reverse_direction() -> void:
	facing_dir *= -1
	orientation.face_dir(facing_dir)

func check_for_ledge() -> bool:
	return not ledge_ray_cast.is_colliding()

func handle_wall_collision() -> void:
	reverse_direction()

func patrol() -> void:
	var on_ledge = check_for_ledge()
	if enemy.is_on_floor() and on_ledge:
		reverse_direction()

	if enemy.is_on_wall():
		if player_detection_area and player_detection_area.is_player_detected:
			return
		else:
			handle_wall_collision()

	# Move at patrol speed
	var new_velocity = Vector2(patrol_move_speed * facing_dir, enemy.velocity.y)
	move(new_velocity)

func move_toward_target(target: Node2D, tolerance: float) -> bool:
	var distance = enemy.global_position.distance_to(target.global_position)

	# Stop moving if within tolerance
	if distance <= tolerance:
		return true

	# Determine direction to target
	var x_direction = 1 if target.global_position.x - enemy.global_position.x > 0 else -1

	# If the player crosses sides, adjust direction
	if facing_dir != x_direction:
		facing_dir = x_direction
		orientation.face_dir(facing_dir)

	# Handle ledges
	if enemy.is_on_floor() and check_for_ledge():
		return false  # Stop at ledge temporarily, but continue logic

	# Handle walls
	if enemy.is_on_wall():
		if x_direction != facing_dir:
			# If the player is on the other side of the wall, turn around
			facing_dir = x_direction
			orientation.face_dir(facing_dir)
		# Ensure movement resumes even if at a wall
		var updated_velocity = Vector2(pursue_move_speed * facing_dir, enemy.velocity.y)
		move(updated_velocity)
		return false  # Continue moving after adjusting

	# Move toward the target
	var speed = pursue_move_speed
	var new_velocity = Vector2(speed * facing_dir, enemy.velocity.y)
	move(new_velocity)

	return false  # Target not yet reached
	
