extends CharacterBody2D
class_name Player

@export_group("Basic Movement")
@export var speed := 300
@export var acceleration := 700
@export var friction := 1100
@export var terminal_velocity_x := 1000
@export var terminal_velocity_y := 1000
@export var ground_dash_timer := 0.2

@export_group("Jump")
@export var jump_velocity := -450
@export var coyote_timer := 0.15
@export var jump_buffer := 0.25
@export var air_dash_speed := 1000
@export var air_dash_vertical_boost := -1050
@export var ground_pound_speed := 2000

var direction := Vector2.ZERO

var gravity_multiplier := 1.0
var is_jumping := false
var short_hop := true
var is_coyote_time := false: set = set_is_coyote_time
var is_jump_buffer := false: set = set_is_jump_buffer
var has_air_dash := false
var has_ground_pound := false
var is_ground_pounding := false

func _physics_process(delta: float) -> void:
	# On floor prior to moving this tick
	var starting_on_floor = is_on_floor()
	
	apply_gravity(delta)
	get_input()
	
	apply_movement(delta)
	# Enforce terminal velocity in both directions
	velocity.x = clamp(velocity.x, -terminal_velocity_x, terminal_velocity_x)
	
	move_and_slide()

	# On floor after moving this tick
	var ending_on_floor = is_on_floor()
	
	if starting_on_floor and !ending_on_floor:
		is_coyote_time = true
	if !starting_on_floor and ending_on_floor:
		gravity_multiplier = 1.0
		has_air_dash = true
		has_ground_pound = false
		
	if ending_on_floor:
		is_ground_pounding = false
		# If the character lands while jump buffer is active, execute the jump
		if is_jump_buffer:
			is_jumping = true
			is_jump_buffer = false # Clear jump buffer after using it

func get_input():
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_coyote_time):
		is_jumping = true
		has_ground_pound = true
	elif Input.is_action_just_pressed("jump") and velocity.y > 0 and not is_on_floor():
		is_jump_buffer = true
	if Input.is_action_just_released("jump") and velocity.y < 0:
		short_hop = true
	if Input.is_action_just_pressed("air_dash") and has_air_dash:
		air_dash()
	if Input.is_action_just_pressed("ground_pound") and has_ground_pound:
		is_ground_pounding = true
		ground_pound()
		
	direction.x = Input.get_axis("move_left", "move_right")

func apply_gravity(delta: float):
	if not is_on_floor() and gravity_multiplier > 0.0:
		velocity += get_gravity() * gravity_multiplier * delta
		velocity.y = min(velocity.y, terminal_velocity_y)
		
		# Apply short hop if jump was released early and we're still moving upward
		if short_hop and velocity.y < 0:
			velocity.y *= 0.5 * gravity_multiplier # Reduce upward velocity to create short hop effect

func apply_movement(delta: float):
	if is_jumping:
		velocity.y = jump_velocity
		is_jumping = false
		short_hop = false
		is_jump_buffer = false
	
	if not is_ground_pounding and direction:
		# Check if character is moving in the opposite direction of the input
		if velocity.x != 0 and sign(velocity.x) != sign(direction.x) and has_air_dash:
			# Start halfway from the current speed, in the opposite direction
			velocity.x = min(direction.x * abs(velocity.x) * 0.5, terminal_velocity_x)
		else:

			# Gradually reach full speed in the current direction
			velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
			# Change this back to flip_h when using a real sprite
			$Sprite2D.flip_v = direction.x < 0
	else:
		# Apply friction when there's no input
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func air_dash():
	has_air_dash = false
	gravity_multiplier = 0.0
	var air_dash_direction = -1 if $Sprite2D.flip_v else 1
	# Directly set velocity.x with respect to direction and terminal velocity
	var dash_tween = create_tween()
	dash_tween.tween_property(self, "velocity:x", air_dash_direction * air_dash_speed, 0.15)
	dash_tween.connect("finished", _on_dash_tween_completed)

func set_is_coyote_time(new_value: bool):
	if new_value != true:
		return
	is_coyote_time = new_value
	await get_tree().create_timer(coyote_timer).timeout
	is_coyote_time = false

func set_is_jump_buffer(new_value: bool):
	is_jump_buffer = new_value
	
	if new_value != true:
		return
	
	await get_tree().create_timer(jump_buffer).timeout
	is_jump_buffer = false

func _on_dash_tween_completed():
	gravity_multiplier = 1.0
	velocity.x = move_toward(velocity.x, 0, friction * 0.25)

	if is_on_floor():
		await get_tree().create_timer(ground_dash_timer).timeout
		has_air_dash = true

func ground_pound():
	var spin_direction = -1 if $Sprite2D.flip_v else 1
	velocity = Vector2.ZERO
	gravity_multiplier = 0.0
	
	var ground_pound_tween = create_tween()
	ground_pound_tween.tween_property($Sprite2D, "rotation_degrees", $Sprite2D.rotation_degrees + 720 * spin_direction, 0.35)
	ground_pound_tween.connect("finished", _on_ground_pound_spin_completed)

func _on_ground_pound_spin_completed():
	$Sprite2D.rotation_degrees = 0
	print("heyoo, ground pound spin completed")
	gravity_multiplier = 10.0
	velocity.y = ground_pound_speed
