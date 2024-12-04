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
@onready var slide_state: SlideState = $LimboHSM/SlideState
@onready var melee_attack1_state: AttackState = $LimboHSM/MeleeAttack1State
@onready var melee_attack2_state: AttackState = $LimboHSM/MeleeAttack2State
@onready var melee_attack3_state: AttackState = $LimboHSM/MeleeAttack3State

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var direction_pointer: Marker2D = $DirectionPointer

@export var terminal_velocity_y := 1000
@export var coyote_timer := 0.15
@export var boost_jump_timer := 0.15
@export var jump_buffer_timer := 0.25
@export var no_turnaround_timer := 0.15
@export var air_dash_speed := 900.0
@export var turnaround_friction_multiplier := 2.0

var reset_position: Vector2
var gravity_multiplier := 1.0
var direction := 0.0
var is_coyote_time := false: set = set_is_coyote_time
var can_boost_jump := false: set = set_can_boost_jump
var can_boost_jump_forward := false: set = set_can_boost_jump_forward
var cannot_turnaround := false: set = set_cannot_turnaround
var jump_buffered := false: set = set_jump_buffered
var current_active_state := ""
var previous_active_state := ""

var can_move := true
var can_attack := true

func _ready():
	handle_unlocks()
	_init_state_machine()
	%Sprite2D.flip_h = PlayerConfig.facing_direction < 0

func _init_state_machine():
	# Transitions into landed_state
	hsm.add_transition(air_state, landing_state, &"landed")
	hsm.add_transition(air_dash_state, landing_state, &"landed")
	hsm.add_transition(ground_pound_state, landing_state, &"ground_pound_landed")
	hsm.add_transition(wall_jump_state, landing_state, &"landed")
	hsm.add_transition(glide_state, landing_state, &"landed")

	# Transitions into air_state
	hsm.add_transition(landing_state, air_state, &"in_air")
	hsm.add_transition(idle_state, air_state, &"in_air")
	hsm.add_transition(move_state, air_state, &"in_air")
	hsm.add_transition(air_dash_state, air_state, &"in_air")
	hsm.add_transition(wall_jump_state, air_state, &"in_air")
	hsm.add_transition(glide_state, air_state, &"in_air")
	hsm.add_transition(slide_state, air_state, &"in_air")
	
	# Transitions into air_dash_state
	hsm.add_transition(air_state, air_dash_state, &"air_dash")
	hsm.add_transition(glide_state, air_dash_state, &"air_dash")
	hsm.add_transition(ground_pound_state, air_dash_state, &"boosted_air_dash")

	# Transitions into ground_pound_state (if unlocked)
	hsm.add_transition(air_state, ground_pound_state, &"ground_pound")
	hsm.add_transition(air_dash_state, ground_pound_state, &"ground_pound")
	hsm.add_transition(glide_state, ground_pound_state, &"ground_pound")

	# Transitions into wall_jump_state
	hsm.add_transition(air_state, wall_jump_state, &"wall_jump")
	hsm.add_transition(air_dash_state, wall_jump_state, &"wall_jump")
	hsm.add_transition(glide_state, wall_jump_state, &"wall_jump")

	# Transitions into glide_state
	hsm.add_transition(air_state, glide_state, &"glide")
	hsm.add_transition(air_dash_state, glide_state, &"glide")

	# Transitions into slide_state
	hsm.add_transition(idle_state, slide_state, &"slide")
	hsm.add_transition(move_state, slide_state, &"slide")

	# Transitions into idle_state
	hsm.add_transition(move_state, idle_state, &"movement_stopped")
	hsm.add_transition(landing_state, idle_state, &"movement_stopped")
	hsm.add_transition(slide_state, idle_state, &"movement_stopped")
	hsm.add_transition(melee_attack1_state, idle_state, &"attack_ended")
	hsm.add_transition(melee_attack2_state, idle_state, &"attack_ended")
	hsm.add_transition(melee_attack3_state, idle_state, &"attack_ended")

	# Transitions into move_state
	hsm.add_transition(idle_state, move_state, &"movement_started")
	hsm.add_transition(landing_state, move_state, &"movement_started")
	hsm.add_transition(slide_state, move_state, &"movement_started")

	# Transitions into melee_attack_states
	hsm.add_transition(idle_state, melee_attack1_state, &"melee_attack1")
	hsm.add_transition(melee_attack1_state, melee_attack2_state, &"melee_attack2")
	hsm.add_transition(melee_attack2_state, melee_attack3_state, &"melee_attack3")

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
	if PlayerConfig.facing_direction != facing_direction and direction != 0 and current_active_state not in PlayerConfig.NON_FLIP_SPRITE_STATES and not cannot_turnaround:
		PlayerConfig.facing_direction = facing_direction
		direction_pointer.position.x = facing_direction * 16
		%Sprite2D.flip_h = facing_direction < 0

	handle_movement(delta)

	if Input.is_action_just_pressed("jump") and PlayerConfig.current_jumps == 0 and can_move and not is_on_floor():
			jump_buffered = true

func handle_movement(delta: float) -> void:
	if direction != 0 and can_move:
		var is_turning_around = (sign(velocity.x) != direction and velocity.x != 0)
		if is_turning_around:
			# Apply stronger friction to stop the character quickly
			velocity.x = move_toward(
				velocity.x,
				0,
				PlayerConfig.friction * turnaround_friction_multiplier * delta
			)
		else:
			# Normal movement
			velocity.x = move_toward(
				velocity.x,
				direction * PlayerConfig.speed,
				PlayerConfig.acceleration * delta
			)
	elif direction == 0 and can_move:
		# Apply normal friction when no input
		velocity.x = move_toward(velocity.x, 0, PlayerConfig.friction * delta)
	else:
		velocity.x = 0
		if current_active_state != "GroundPoundState":
			$AnimationPlayer.play("idle")
	
	velocity.x = clamp(velocity.x, -PlayerConfig.max_speed, PlayerConfig.max_speed)
	velocity.y = clamp(velocity.y, -terminal_velocity_y, terminal_velocity_y)


func apply_gravity(delta: float):
	if not is_on_floor() and gravity_multiplier > 0.0:
		velocity += get_gravity() * gravity_multiplier * delta
		velocity.y = min(velocity.y, terminal_velocity_y)
	# Note: The bottom is probably the way it "should be," but maintaining the current y velocity on dash feels more fun so far. Leaving this commented for future reference.
	# elif not is_on_floor() and gravity_multiplier == 0.0:
		# velocity.y = 0

func jump():
	jump_buffered = false
	if can_boost_jump:
		velocity.y = PlayerConfig.jump_velocity * 1.2
	else:
		if can_boost_jump_forward:
			do_sick_flip()
			velocity.x = (air_dash_speed / 1.4) * PlayerConfig.facing_direction

		velocity.y = PlayerConfig.jump_velocity

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
		MetSys.store_object(unlockable)
		unlockable.queue_free()

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

func do_sick_flip():
	var jump_squeeze_tween = create_tween()

	jump_squeeze_tween.tween_property(
		%Sprite2D,
		"rotation_degrees",
		%Sprite2D.rotation_degrees + (360 * PlayerConfig.facing_direction),
		0.5
	).set_trans(Tween.TRANS_CIRC)

func _on_hurtbox_hurt(hitbox: Hitbox, damage: float) -> void:
	print("owwww! ", hitbox.get_children(), " ", damage)
	PlayerConfig.health -= damage
	$Hurtbox.is_invincible = true
	$BlinkingAnimationPlayer.play("blink")
	await $BlinkingAnimationPlayer.animation_finished
	$Hurtbox.is_invincible = false

func handle_unlocks():
	if PlayerConfig.abilities.size() == 0:
		return

	for ability in PlayerConfig.abilities:
		if ability == &"double_jump":
			PlayerConfig.max_jumps = 2
		if ability == &"air_dash":
			PlayerConfig.max_air_dashes = 1

func on_enter():
	# Position for kill system. Assigned when entering new room (see Game.gd).
	reset_position = position

func set_cannot_turnaround(new_val: bool):
	cannot_turnaround = new_val
	await get_tree().create_timer(no_turnaround_timer).timeout
	cannot_turnaround = false

func allow_attack():
	can_attack = true
