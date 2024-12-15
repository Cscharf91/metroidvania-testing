class_name Enemy
extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var ray_casts_pivot: Marker2D = $RayCasts
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var player_detection_area: PlayerDetectionArea  = $PlayerDetectionArea

@export var default_sprite_dir := 1
@export var is_flying: bool = false
@export var patrol_move_speed: float = 100.0
@export var pursue_move_speed: float = 135.0
@export var max_health: float = 100.0
@export var attacks_player: bool = true

var current_health: float
var gravity_multiplier: float = 1.0
var player_detected: bool = false
var facing_dir: float
var ray_casts: Array[RayCast2D] = []

func _ready() -> void:
	current_health = max_health
	facing_dir = default_sprite_dir

	if facing_dir == 1:
		# TODO: radius is gonna be a problem if I use other collision shapes down the line, figure it out later lol
		ray_casts_pivot.position.x = collision_shape.shape.radius
	else:
		ray_casts_pivot.position.x = -collision_shape.shape.radius
	
	for node in ray_casts_pivot.get_children():
		if node is RayCast2D:
			ray_casts.append(node)
	
	player_detection_area.player_detected.connect(_on_player_detected)
	player_detection_area.player_lost.connect(_on_player_lost)

func _on_hurtbox_hurt(hitbox: Variant) -> void:
	print("you hurt the enemy for: ", hitbox.damage)
	
	if current_health <= 0.0:
		die()
		return
		
	current_health -= hitbox.damage
	apply_knockback(hitbox.knockback)

func move_in_direction(dir: float, skip_ledge_check: bool = false) -> void:
	if not skip_ledge_check and check_for_ledge():
		reverse_direction()
		return
	
	var speed = patrol_move_speed if not player_detected else pursue_move_speed
	var new_velocity = Vector2(speed * dir, velocity.y)
	move(new_velocity)
	update_facing()

func reverse_direction() -> void:
	facing_dir *= -1
	update_facing()
	move_in_direction(facing_dir, true)
	player_detection_area.reverse_ray_directions()

func apply_knockback(amount: Vector2) -> void:
	print("amount of knockback: ", amount)

func die() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if not is_flying and not is_on_floor():
		apply_gravity(_delta)

func apply_gravity(delta: float):
	if not is_on_floor() and gravity_multiplier > 0.0:
		velocity += get_gravity() * gravity_multiplier * delta


func move(new_velocity: Vector2) -> void:
	velocity = lerp(velocity, new_velocity, 0.2)
	move_and_slide()

func update_facing() -> void:
	face_dir(facing_dir)

func face_dir(dir: float) -> void:
	ray_casts_pivot.position.x = collision_shape.shape.radius if dir > 0 else -collision_shape.shape.radius
	if default_sprite_dir == 1:
		sprite.flip_h = true if dir > 0 else false
	else:
		sprite.flip_h = true if dir < 0 else false

func check_for_ledge() -> bool:
	for ray in ray_casts:
		if ray.name == "LedgeRayCast" and not ray.is_colliding():
			return true
	return false

func _on_player_detected() -> void:
	player_detected = true

func _on_player_lost() -> void:
	player_detected = false
