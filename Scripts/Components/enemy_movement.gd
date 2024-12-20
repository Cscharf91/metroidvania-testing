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

func move_in_direction(dir: float, skip_ledge_check: bool = false) -> void:
	if enemy.is_on_floor() and not skip_ledge_check and check_for_ledge():
		if player_detection_area.is_player_detected:
			return
		reverse_direction()
		return
	
	var speed = patrol_move_speed if not player_detection_area.is_player_detected else pursue_move_speed
	var new_velocity = Vector2(speed * dir, enemy.velocity.y)
	move(new_velocity)
	if orientation.facing_dir != dir:
		orientation.face_dir(dir)

func reverse_direction() -> void:
	facing_dir *= -1
	move_in_direction(facing_dir, true)


func check_for_ledge() -> bool:
	if ledge_ray_cast.is_colliding():
		return false
	return true
