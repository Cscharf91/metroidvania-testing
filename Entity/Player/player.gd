extends CharacterBody2D
class_name Player

@onready var ImpactEffect: PackedScene = preload("res://Effects/impact_effect.tscn")

@export_group("Basic Movement")
@export var speed := 300
@export var acceleration := 700
@export var friction := 1100
@export var default_max_speed := 900
@export var boost_max_speed := 1200
@export var terminal_velocity_x := default_max_speed: set = set_terminal_velocity_x
@export var terminal_velocity_y := 1000

@export_group("Jump")
@export var jump_velocity := -450
@export var coyote_timer := 0.15
@export var air_dash_hold_timer := 0.15
@export var jump_buffer := 0.25
@export var air_dash_speed := 1200
@export var air_dash_landing_jump_velocity := -500
@export var ground_pound_speed := 2000

var direction := Vector2.ZERO

var gravity_multiplier := 1.0
var is_jumping := false
var short_hop := true
var is_coyote_time := false: set = set_is_coyote_time
var is_jump_buffer := false: set = set_is_jump_buffer
var max_air_dashes := 1
var current_air_dashes := max_air_dashes
var is_currently_air_dashing := false
var has_ground_pound := false
var is_ground_pounding := false
var landed_after_dash := false: set = set_landed_after_dash

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
	handle_after_moving(starting_on_floor, ending_on_floor)

func get_input():
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_coyote_time):
		is_jumping = true
		has_ground_pound = true
	elif Input.is_action_just_pressed("jump") and velocity.y > 0 and not is_on_floor():
		is_jump_buffer = true
	if Input.is_action_just_released("jump") and velocity.y < 0:
		short_hop = true
	if Input.is_action_just_pressed("air_dash") and not is_on_floor() and current_air_dashes > 0:
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
		jump()
	
	if not is_ground_pounding and direction:
		if not is_currently_air_dashing:
			$AnimationPlayer.play("run")
		# Check if character is moving in the opposite direction of the input
		if velocity.x != 0 and sign(velocity.x) != sign(direction.x) and current_air_dashes:
			# Start halfway from the current speed, in the opposite direction
			velocity.x = min(direction.x * abs(velocity.x) * 0.5, terminal_velocity_x)
		else:
			# Gradually reach full speed in the current direction
			velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
			if direction.x != 0:
				$Sprite2D.flip_h = direction.x > 0
	else:
		# Apply friction when there's no input
		if not is_currently_air_dashing:
			$AnimationPlayer.play("idle")
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func jump():
	is_jumping = false
	short_hop = false
	is_jump_buffer = false

	if landed_after_dash:
		print("Boost jump")
		var boost_jump_direction = 1 if $Sprite2D.flip_h else -1
		
		terminal_velocity_x = boost_max_speed
		landed_after_dash = false
		velocity.y = air_dash_landing_jump_velocity
		velocity.x = air_dash_speed * boost_jump_direction
	else:
		velocity.y = jump_velocity

func air_dash():
	is_currently_air_dashing = true
	current_air_dashes -= 1
	gravity_multiplier = 0.0

	var air_dash_direction = 1 if $Sprite2D.flip_h else -1
	$AnimationPlayer.play("air_dash_" + ("right" if air_dash_direction == 1 else "left"))

	# Directly set velocity.x with respect to direction and terminal velocity
	var dash_tween = create_tween()
	var total_air_dash_speed = air_dash_speed if not is_ground_pounding else air_dash_speed * 2
	dash_tween.tween_property(self, "velocity:x", air_dash_direction * total_air_dash_speed, 0.1)
	dash_tween.connect("finished", _on_dash_tween_completed)

func ground_pound():
	var spin_direction = -1 if $Sprite2D.flip_v else 1
	velocity = Vector2.ZERO
	gravity_multiplier = 0.0
	
	var ground_pound_tween = create_tween()
	ground_pound_tween.tween_property($Sprite2D, "rotation_degrees", $Sprite2D.rotation_degrees + 360 * spin_direction, 0.25)
	ground_pound_tween.connect("finished", _on_ground_pound_spin_completed)

func handle_after_moving(starting_on_floor: bool, ending_on_floor: bool):
	if starting_on_floor and !ending_on_floor:
		is_coyote_time = true
		
	if !starting_on_floor and ending_on_floor:
		gravity_multiplier = 1.0
		has_ground_pound = false
		# If the player lands during an air dash
		if current_air_dashes < max_air_dashes:
			landed_after_dash = true
		
	if not ending_on_floor:
		if not is_currently_air_dashing:
			$AnimationPlayer.play("jump")
	
	if ending_on_floor:
		$Sprite2D.scale = Vector2(1, 1)
		$Sprite2D.rotation_degrees = 0
		if is_ground_pounding:
			var impact_effect = ImpactEffect.instantiate()
			impact_effect.global_position = global_position
			get_parent().add_child(impact_effect)
			impact_effect.emitting = true
			
			is_ground_pounding = false
		current_air_dashes = max_air_dashes
		is_currently_air_dashing = false

		# If the player lands while jump buffer is active, execute the jump
		if is_jump_buffer:
			is_jumping = true
			is_jump_buffer = false # Clear jump buffer after using it

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

func set_landed_after_dash(new_value: bool):
	landed_after_dash = new_value

	if new_value != true:
		return
	
	await get_tree().create_timer(0.15).timeout
	landed_after_dash = false

func set_terminal_velocity_x(new_value: int):
	terminal_velocity_x = new_value

	if new_value != default_max_speed:
		return
	
	await get_tree().create_timer(0.15).timeout
	terminal_velocity_x = default_max_speed

func _on_dash_tween_completed():
	gravity_multiplier = 1.0
	velocity.x = move_toward(velocity.x, speed, friction * 0.25)
	
	await get_tree().create_timer(air_dash_hold_timer).timeout
	is_currently_air_dashing = false

func _on_ground_pound_spin_completed():
	var stretch_tween = create_tween()
	# Set to ease in and out
	stretch_tween.tween_property($Sprite2D, "scale", Vector2(0.6, 1.3), 0.05)
	$Sprite2D.rotation_degrees = 0
	gravity_multiplier = 5.0
	velocity.y = ground_pound_speed
