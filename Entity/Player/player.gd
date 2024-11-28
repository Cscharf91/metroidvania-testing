extends CharacterBody2D
class_name Player

@onready var ImpactEffect: PackedScene = preload("res://Effects/impact_effect.tscn")
@onready var hsm: LimboHSM = $LimboHSM
@onready var idle_state: IdleState = $LimboHSM/IdleState
@onready var move_state: MoveState = $LimboHSM/MoveState
@onready var air_state: AirState = $LimboHSM/AirState
@onready var air_dash_state: AirDashState = $LimboHSM/AirDashState
@onready var ground_pound_state: GroundPoundState = $LimboHSM/GroundPoundState
@onready var landing_state: LandingState = $LimboHSM/LandingState
@onready var wall_jump_state: WallJumpState = $LimboHSM/WallJumpState
@onready var glide_state: GlideState = $LimboHSM/GlideState

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var direction_pointer: Marker2D = $DirectionPointer

@export var terminal_velocity_y := 1000
@export var coyote_timer := 0.15
@export var boost_jump_timer := 0.25
@export var jump_buffer_timer := 0.25
@export var air_dash_speed := 900.0

var gravity_multiplier := 1.0
var direction := 0.0
var is_coyote_time := false: set = set_is_coyote_time
var can_boost_jump := false: set = set_can_boost_jump
var can_boost_jump_forward := false: set = set_can_boost_jump_forward
var jump_buffered := false: set = set_jump_buffered
var current_active_state := ""
var previous_active_state := ""
var can_move := true

func _ready():
	_init_state_machine()
	%Sprite2D.flip_h = PlayerConfig.facing_direction > 0

func _init_state_machine():
	# Transitions into landed_state
	hsm.add_transition(air_state, landing_state, &"landed")
	hsm.add_transition(air_dash_state, landing_state, &"landed")
	hsm.add_transition(ground_pound_state, landing_state, &"ground_pound_landed")
	hsm.add_transition(wall_jump_state, landing_state, &"landed")
	hsm.add_transition(glide_state, landing_state, &"landed")

	# Transitions out of landed_state
	hsm.add_transition(landing_state, idle_state, &"movement_stopped")
	hsm.add_transition(landing_state, move_state, &"movement_started")
	hsm.add_transition(landing_state, air_state, &"in_air")

	# Transitions into air_state
	hsm.add_transition(idle_state, air_state, &"in_air")
	hsm.add_transition(move_state, air_state, &"in_air")
	hsm.add_transition(air_dash_state, air_state, &"in_air")
	hsm.add_transition(wall_jump_state, air_state, &"in_air")
	hsm.add_transition(glide_state, air_state, &"in_air")
	
	# Transitions into air_dash_state
	hsm.add_transition(air_state, air_dash_state, &"air_dash")
	hsm.add_transition(glide_state, air_dash_state, &"air_dash")
	hsm.add_transition(ground_pound_state, air_dash_state, &"boosted_air_dash")

	# Transitions into ground_pound_state (if unlocked)
	hsm.add_transition(air_state, ground_pound_state, &"ground_pound")
	hsm.add_transition(air_dash_state, ground_pound_state, &"ground_pound")

	# Transitions into wall_jump_state
	hsm.add_transition(air_state, wall_jump_state, &"wall_jump")
	hsm.add_transition(air_dash_state, wall_jump_state, &"wall_jump")
	hsm.add_transition(glide_state, wall_jump_state, &"wall_jump")

	# Transitions into glide_state
	hsm.add_transition(air_state, glide_state, &"glide")
	hsm.add_transition(air_dash_state, glide_state, &"glide")
	
	# One-off transitions
	hsm.add_transition(move_state, idle_state, &"movement_stopped")
	hsm.add_transition(idle_state, move_state, &"movement_started")

	hsm.initialize(self)
	hsm.set_initial_state(idle_state)
	hsm.set_active(true)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var actionables = %ActionDetectionArea.get_overlapping_areas().filter(
			func(area): return area is Actionable
		)
		if actionables.size() > 0:
			var actionable: Actionable = actionables[0]
			actionable.action()


func _physics_process(delta: float) -> void:
	previous_active_state = current_active_state
	current_active_state = hsm.get_active_state().name
	apply_gravity(delta)

	direction = Input.get_axis("move_left", "move_right")

	var facing_direction = 1 if direction > 0 else -1
	if PlayerConfig.facing_direction != facing_direction and direction != 0 and current_active_state not in PlayerConfig.NON_FLIP_SPRITE_STATES:
		PlayerConfig.facing_direction = facing_direction
		direction_pointer.position.x = facing_direction * 16
		%Sprite2D.flip_h = facing_direction > 0

	handle_movement(delta)

	if Input.is_action_just_pressed("jump") and PlayerConfig.current_jumps == 0 and can_move and not is_on_floor():
			jump_buffered = true

func handle_movement(delta: float) -> void:
	if direction != 0 and can_move:
		velocity.x = move_toward(
		velocity.x,
		direction * PlayerConfig.speed,
		PlayerConfig.acceleration * delta
		)
	elif direction == 0 and can_move:
		# Apply friction when no input
		velocity.x = move_toward(velocity.x, 0, PlayerConfig.friction * delta)
	else:
			velocity.x = 0
			if current_active_state != "GroundPoundState":
				$AnimationPlayer.play("idle")


func apply_gravity(delta: float):
	if not is_on_floor() and gravity_multiplier > 0.0:
		velocity += get_gravity() * gravity_multiplier * delta
		velocity.y = min(velocity.y, terminal_velocity_y)
	# Note: The bottom is probably the way it "should be," but maintaining the current y velocity on dash feels more fun so far. Leaving this commented for future reference.
	# elif not is_on_floor() and gravity_multiplier == 0.0:
		# velocity.y = 0

func jump():
	jump_buffered = false
	if is_on_floor():
		# one in 10 jumps will be a sick spin or a flipperoo
		var random_number = randi() % 10
		if random_number == 0:
			if randi() % 2:
				do_sick_spin()
			else:
				do_flipperoo()
	if can_boost_jump:
		velocity.y = PlayerConfig.jump_velocity * 1.3
	else:
		if can_boost_jump_forward:
			do_flipperoo()
			velocity.x = air_dash_speed * PlayerConfig.facing_direction

		velocity.y = PlayerConfig.jump_velocity

func save():
	var save_dict = {
		"filename": get_scene_file_path(),
		"name": "Player",
		"parent": get_parent().get_path(),
		"pos_x": position.x,
		"pos_y": position.y,
	}

	return save_dict

func load(data: Dictionary) -> void:
	print("loading data: ", data)

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

func set_can_boost_jump_forward(new_val: bool) -> void:
	can_boost_jump_forward = new_val

	if new_val == false:
		return
	
	await get_tree().create_timer(boost_jump_timer).timeout
	can_boost_jump_forward = false

func set_jump_buffered(new_val: bool) -> void:
	jump_buffered = new_val

	if new_val == false:
		return

	await get_tree().create_timer(jump_buffer_timer).timeout
	jump_buffered = false


func _on_action_detection_area_area_entered(area: Area2D) -> void:
	if area is Unlockable:
		var unlockable: Unlockable = area
		PlayerConfig.unlock_ability(unlockable.unlock_key)
		area.queue_free()

func create_dash_effect():
	var dash_effect = %Sprite2D.duplicate()
	get_parent().add_child(dash_effect)
	dash_effect.position = position
	dash_effect.flip_h = %Sprite2D.flip_h
	var tint_color = Color(0.2, 0.2, 1, 0.4)
	dash_effect.modulate = dash_effect.modulate.blend(tint_color)


	var animation_time = %FastMovementEffectTimer.wait_time / 3
	await get_tree().create_timer(animation_time).timeout
	dash_effect.modulate.a = 0.2
	await get_tree().create_timer(animation_time).timeout
	dash_effect.queue_free()


func _on_fast_movement_effect_timer_timeout() -> void:
	create_dash_effect()

func do_sick_spin():
	var jump_squeeze_tween = create_tween()

	jump_squeeze_tween.tween_property(
		%Sprite2D,
		"scale",
		Vector2(-1.0, 1.0),
		0.25
	).set_trans(Tween.TRANS_ELASTIC)

	jump_squeeze_tween.tween_property(
		%Sprite2D,
		"scale",
		Vector2(1.0, 1.0),
		0.5
	).set_trans(Tween.TRANS_ELASTIC)

func do_flipperoo():
	var jump_squeeze_tween = create_tween()

	jump_squeeze_tween.tween_property(
		%Sprite2D,
		"rotation_degrees",
		%Sprite2D.rotation_degrees + (360 if randi() % 2 else -360),
		0.5
	).set_trans(Tween.TRANS_CIRC)

func _on_hurtbox_hurt(hitbox: Hitbox, damage: float) -> void:
	print("owwww! ", hitbox.get_children(), " ", damage)
	PlayerConfig.health -= damage
	$Hurtbox.is_invincible = true
	$BlinkingAnimationPlayer.play("blink")
	await $BlinkingAnimationPlayer.animation_finished
	$Hurtbox.is_invincible = false