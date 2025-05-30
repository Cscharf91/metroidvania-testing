class_name CutsceneMovingProp
extends Area2D

# Enum for 8-directional movement
enum Direction {
	N, NW, W, SW, S, SE, E, NE
}

@export var direction: Direction = Direction.S
@export var move_speed: float = 100.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var _velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	_set_velocity_from_direction()

	if animated_sprite_2d and "moving" in animated_sprite_2d.sprite_frames.get_animation_names():
		animated_sprite_2d.play("moving")

func _physics_process(delta: float) -> void:
	global_position += _velocity * delta

func _set_velocity_from_direction() -> void:
	match direction:
		Direction.N:
			_velocity = Vector2(0, -move_speed)
		Direction.NW:
			_velocity = Vector2(-1, -1).normalized() * move_speed
		Direction.W:
			_velocity = Vector2(-move_speed, 0)
		Direction.SW:
			_velocity = Vector2(-1, 1).normalized() * move_speed
		Direction.S:
			_velocity = Vector2(0, move_speed)
		Direction.SE:
			_velocity = Vector2(1, 1).normalized() * move_speed
		Direction.E:
			_velocity = Vector2(move_speed, 0)
		Direction.NE:
			_velocity = Vector2(1, -1).normalized() * move_speed

func _on_area_entered(_area: Area2D) -> void:
	queue_free()

	# if animated_sprite_2d and "collision" in animated_sprite_2d.sprite_frames.get_animation_names():
	# 	animated_sprite_2d.play("collision")
	# 	await animated_sprite_2d.animation_finished
	# 	queue_free()