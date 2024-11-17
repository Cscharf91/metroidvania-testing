extends CharacterBody2D
class_name Player

@onready var ImpactEffect: PackedScene = preload("res://Effects/impact_effect.tscn")
@onready var hsm: LimboHSM = $LimboHSM
@onready var idle_state: LimboState = $LimboHSM/IdleState
@onready var move_state: LimboState = $LimboHSM/MoveState
@onready var air_state: LimboState = $LimboHSM/AirState
@onready var air_dash_state: LimboState = $LimboHSM/AirDashState
@onready var ground_pound_state: LimboState = $LimboHSM/GroundPoundState

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var terminal_velocity_y := 1000
@export var coyote_timer := 0.15
@export var air_dash_speed := 1200

var gravity_multiplier := 1.0
var direction := 0.0
var is_coyote_time := false: set = set_is_coyote_time
var can_boost_jump := false: set = set_can_boost_jump
var boost_jump_timer := 0.25

func _ready():
	_init_state_machine()

func _init_state_machine():
	# Transitions into move_state
	hsm.add_transition(idle_state, move_state, &"movement_started")
	hsm.add_transition(air_state, move_state, &"movement_started")
	hsm.add_transition(air_dash_state, move_state, &"movement_started")

	# Transitions into idle_state
	hsm.add_transition(move_state, idle_state, &"movement_stopped")
	hsm.add_transition(air_state, idle_state, &"movement_stopped")
	hsm.add_transition(air_dash_state, idle_state, &"movement_stopped")
	hsm.add_transition(ground_pound_state, idle_state, &"ground_pound_landed")

	# Transitions into air_state
	hsm.add_transition(idle_state, air_state, &"in_air")
	hsm.add_transition(move_state, air_state, &"in_air")
	
	# Transitions into air_dash_state
	hsm.add_transition(air_state, air_dash_state, &"air_dash")
	hsm.add_transition(ground_pound_state, air_dash_state, &"boosted_air_dash")

	# Transitions into ground_pound_state
	hsm.add_transition(air_state, ground_pound_state, &"ground_pound")
	hsm.add_transition(air_dash_state, ground_pound_state, &"ground_pound")

	hsm.initialize(self)
	hsm.set_initial_state(idle_state)
	var initial_state = hsm.get_initial_state()
	print("Initial state: ", initial_state)
	hsm.set_active(true)
	print("Active state: ", hsm.is_active())

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	direction = Input.get_axis("move_left", "move_right")
	handle_movement(delta)

func handle_movement(delta: float) -> void:
	if direction != 0:
		velocity.x = move_toward(
		velocity.x,
		direction * PlayerStats.speed,
		PlayerStats.acceleration * delta
		)
	else:
		# Apply friction when no input
		velocity.x = move_toward(velocity.x, 0, PlayerStats.friction * delta)


func apply_gravity(delta: float):
	if not is_on_floor() and gravity_multiplier > 0.0:
		velocity += get_gravity() * gravity_multiplier * delta
		velocity.y = min(velocity.y, terminal_velocity_y)
		
		# Apply short hop if jump was released early and we're still moving upward
		# if short_hop and velocity.y < 0:
			# velocity.y *= 0.5 * gravity_multiplier # Reduce upward velocity to create short hop effect

# 		# Check if character is moving in the opposite direction of the input
# 		if velocity.x != 0 and sign(velocity.x) != sign(direction.x) and current_air_dashes:
# 			# Start halfway from the current speed, in the opposite direction
# 			velocity.x = min(direction.x * abs(velocity.x) * 0.5, terminal_velocity_x)
# 		else:
# 			# Gradually reach full speed in the current direction
			# velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
# 			if direction.x != 0:
# 				$Sprite2D.flip_h = direction.x > 0
# 	else:
# 		# Apply friction when there's no input
# 		if not is_currently_air_dashing:
# 			$AnimationPlayer.play("idle")
# 		velocity.x = move_toward(velocity.x, 0, friction * delta)

func jump():
	if can_boost_jump:
		print("Boost jump")
		var boost_jump_direction = 1 if %Sprite2D.flip_h else -1

		velocity.y = PlayerStats.jump_velocity * 1.2
		velocity.x = air_dash_speed * boost_jump_direction
	else:
		velocity.y = PlayerStats.jump_velocity

func set_is_coyote_time(new_value: bool):
	if new_value != true:
		return
	is_coyote_time = new_value
	await get_tree().create_timer(coyote_timer).timeout
	is_coyote_time = false

func set_can_boost_jump(new_val: bool) -> void:
	can_boost_jump = new_val

	if new_val == false:
		return

	await get_tree().create_timer(boost_jump_timer).timeout
	can_boost_jump = false
	print("Boost jump timer expired")