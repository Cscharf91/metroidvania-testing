class_name EnemyOrientation
extends Node

@export var sprite: Sprite2D
@export var collision_shape: CollisionShape2D
@export var ray_casts_pivot: Node
@export var hitboxes_parent: Node
@export var player_detection_area: PlayerDetectionArea
@export var default_sprite_dir := 1

var facing_dir: float
var ray_casts: Array[RayCast2D] = []

func _ready():
	facing_dir = default_sprite_dir
	update_pivot_position()

	if facing_dir == 1:
		# TODO: radius is gonna be a problem if I use other collision shapes down the line, figure it out later lol
		ray_casts_pivot.position.x = collision_shape.shape.radius
	else:
		ray_casts_pivot.position.x = -collision_shape.shape.radius
		flip_hitboxes()
	
	for node in ray_casts_pivot.get_children():
		if node is RayCast2D:
			ray_casts.append(node)

func face_dir(dir: float) -> void:
	facing_dir = dir
	update_sprite()
	update_pivot_position()
	flip_hitboxes()
	if player_detection_area:
		player_detection_area.reverse_ray_directions()

func update_sprite() -> void:
	if default_sprite_dir == 1:
		sprite.flip_h = facing_dir > 0
	else:
		sprite.flip_h = facing_dir < 0

func update_pivot_position() -> void:
	ray_casts_pivot.position.x = collision_shape.shape.radius * facing_dir

func flip_hitboxes() -> void:
	for hitbox in hitboxes_parent.get_children():
		if hitbox is Hitbox:
			hitbox.position.x *= -1