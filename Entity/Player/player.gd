extends CharacterBody2D
class_name Player

@onready var ImpactEffect: PackedScene = preload("res://Effects/impact_effect.tscn")
@onready var hsm: LimboHSM = $LimboHSM
@onready var idle_state: LimboState = $LimboHSM/IdleState
@onready var move_state: LimboState = $LimboHSM/MoveState
@onready var air_state: LimboState = $LimboHSM/AirState
@onready var air_dash_state: LimboState = $LimboHSM/AirDashState
@onready var ground_pound_state: LimboState = $LimboHSM/GroundPoundState
@onready var landing_state: LimboState = $LimboHSM/LandingState

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var terminal_velocity_y := 1000
@export var coyote_timer := 0.15
@export var boost_jump_timer := 0.25
@export var jump_buffer_timer := 0.25
@export var air_dash_speed := 900.0

var gravity_multiplier := 1.0
var direction := 0.0
var is_coyote_time := false: set = set_is_coyote_time
var can_boost_jump := false: set = set_can_boost_jump
var can_boost_jump_forward := false
var jump_buffered := false: set = set_jump_buffered
var current_active_state := ""
var previous_active_state := ""

func _ready():
	_init_state_machine()

func _init_state_machine():
	# Transitions into landed_state
	hsm.add_transition(air_state, landing_state, &"landed")
	hsm.add_transition(air_dash_state, landing_state, &"landed")
	hsm.add_transition(ground_pound_state, landing_state, &"ground_pound_landed")

	# Transitions out of landed_state
	hsm.add_transition(landing_state, idle_state, &"movement_stopped")
	hsm.add_transition(landing_state, move_state, &"movement_started")
	hsm.add_transition(landing_state, air_state, &"in_air")

	# Transitions into air_state
	hsm.add_transition(idle_state, air_state, &"in_air")
	hsm.add_transition(move_state, air_state, &"in_air")
	hsm.add_transition(air_dash_state, air_state, &"in_air")
	
	# Transitions into air_dash_state
	hsm.add_transition(air_state, air_dash_state, &"air_dash")
	hsm.add_transition(ground_pound_state, air_dash_state, &"boosted_air_dash")

	# Transitions into ground_pound_state (if unlocked)
	if PlayerStats.unlocks.ground_pound:
		hsm.add_transition(air_state, ground_pound_state, &"ground_pound")
		hsm.add_transition(air_dash_state, ground_pound_state, &"ground_pound")
	
	# One-off transitions
	hsm.add_transition(move_state, idle_state, &"movement_stopped")
	hsm.add_transition(idle_state, move_state, &"movement_started")

	hsm.initialize(self)
	hsm.set_initial_state(idle_state)
	var initial_state = hsm.get_initial_state()
	print("Initial state: ", initial_state)
	hsm.set_active(true)
	print("Active state: ", hsm.is_active())

func _physics_process(delta: float) -> void:
	previous_active_state = current_active_state
	current_active_state = hsm.get_active_state().name
	apply_gravity(delta)
	direction = Input.get_axis("move_left", "move_right")
	handle_movement(delta)

	if Input.is_action_just_pressed("jump") and PlayerStats.current_jumps == 0 and not is_on_floor():
			jump_buffered = true

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

func jump():
	PlayerStats.current_jumps -= 1
	if can_boost_jump:
		var boost_jump_direction = 1 if %Sprite2D.flip_h else -1

		velocity.y = PlayerStats.jump_velocity * 1.2
		if can_boost_jump_forward:
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
		
	if previous_active_state == "AirDashState":
		can_boost_jump_forward = true

	await get_tree().create_timer(boost_jump_timer).timeout
	can_boost_jump = false
	can_boost_jump_forward = false

func set_jump_buffered(new_val: bool) -> void:
	jump_buffered = new_val

	if new_val == false:
		return

	await get_tree().create_timer(jump_buffer_timer).timeout
	jump_buffered = false