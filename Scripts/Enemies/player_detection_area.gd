class_name PlayerDetectionArea
extends Area2D

signal player_detected
signal player_lost

@export var primary_raycast: RayCast2D
@export var additional_ray_count: int = 5  # Total number of extra rays (evenly split up/down)
@export var raycast_angle: float = 10.0  # Maximum angle offset (degrees) for additional rays
@export var ray_length: float = 100.0  # Length of the rays
@export var lose_player_aggro_time: float

var additional_rays: Array[RayCast2D] = []
var is_player_detected: bool = false
var timer_running: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Ensure the primary raycast is set up
	if primary_raycast:
		primary_raycast.enabled = false

	# Create additional rays
	create_additional_rays()

func create_additional_rays() -> void:
	if primary_raycast == null or additional_ray_count <= 0:
		return

	var marker_parent: Node = primary_raycast.get_parent()
	if not marker_parent or not marker_parent is Marker2D:
		print("Primary RayCast2D must be a child of a Marker2D!")
		return

	var angles = calculate_ray_angles()
	for angle in angles:
		var ray = primary_raycast.duplicate() as RayCast2D
		ray.rotation_degrees = primary_raycast.rotation_degrees + angle
		marker_parent.add_child(ray)
		additional_rays.append(ray)
		ray.enabled = false  # Start disabled

func calculate_ray_angles() -> Array[float]:
	# Prevent division by zero
	if additional_ray_count <= 0:
		return []

	var angles: Array[float] = []  # Explicitly typed array for float angles
	var half_count = float(additional_ray_count) / 2.0  # Ensure float division
	var step = raycast_angle / half_count  # Step size per ray

	for i in range(additional_ray_count):
		var offset = step * ((i / 2.0) + 1.0)  # Ensure i / 2 is float
		if i % 2 == 0:
			angles.append(-offset)  # Downward angle
		else:
			angles.append(offset)   # Upward angle
	return angles

func _physics_process(_delta: float) -> void:
	# Check primary raycast
	if primary_raycast and primary_raycast.enabled:
		if primary_raycast.is_colliding() and primary_raycast.get_collider() is Player:
			detect_player()
			return

	# Check additional rays
	for ray in additional_rays:
		if ray.enabled and ray.is_colliding() and ray.get_collider() is Player:
			detect_player()
			return

func _on_body_entered(body: Player) -> void:
	if body is not Player:
		return
	
	enable_rays()
	timer_running = false

func _on_body_exited(body: Player) -> void:
	if body is not Player:
		return
	
	disable_rays()
	start_lost_timer()

func enable_rays() -> void:
	if primary_raycast:
		primary_raycast.enabled = true
	for ray in additional_rays:
		ray.enabled = true

func disable_rays() -> void:
	if primary_raycast:
		primary_raycast.enabled = false
	for ray in additional_rays:
		ray.enabled = false

func start_lost_timer() -> void:
	if lose_player_aggro_time > 0 and not timer_running:
		timer_running = true
		await get_tree().create_timer(lose_player_aggro_time).timeout
		if not timer_running:
			return
		timer_running = false
		is_player_detected = false
		player_lost.emit()

func detect_player() -> void:
	if not is_player_detected:
		is_player_detected = true
		player_detected.emit()

func reverse_ray_directions() -> void:
	if primary_raycast:
		primary_raycast.rotation_degrees += 180.0

	for ray in additional_rays:
		ray.rotation_degrees += 180.0
