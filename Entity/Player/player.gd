extends CharacterBody2D
class_name Player

@onready var ImpactEffect: PackedScene = preload("res://Effects/impact_effect.tscn")
@onready var hsm: LimboHSM = $LimboHSM
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape = %CollisionShape2D
@onready var state_transitions = $StateTransitions
@onready var idle_state: IdleState = %LimboHSM/IdleState
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var direction_pointer: Marker2D = $DirectionPointer
@onready var frisbee: PackedScene = preload("res://Entity/Player/frisbee.tscn")
@onready var air_state: AirState = $LimboHSM/AirState

@export var terminal_velocity_y := 1000
@export var coyote_timer := 0.15
@export var boost_jump_timer := 0.15
@export var no_turnaround_timer := 0.15
@export var air_dash_speed := 900.0
@export var turnaround_friction_multiplier := 2.0
@export var frisbee_throw_velocity := -250

var reset_position: Vector2
var mid_level_checkpoint_position: Vector2
var gravity_multiplier := 1.0
var direction := 0.0
var is_coyote_time := false: set = set_is_coyote_time
var can_boost_jump := false: set = set_can_boost_jump
var can_boost_jump_forward := false: set = set_can_boost_jump_forward
var cannot_turnaround := false: set = set_cannot_turnaround
var current_active_state := ""
var previous_active_state := ""

var combo := 0: set = set_combo
var combo_charges := 0
var combo_charged := false
var last_jump_position: Vector2
var fall_start_position: Vector2
var current_frisbee: Frisbee
var can_bounce := false

var can_move := true
var can_attack := true

func _ready():
	handle_unlocks()
	_connect_signals()
	on_enter()
	_init_state_machine()
	%Sprite2D.flip_h = PlayerConfig.facing_direction < 0

func _init_state_machine():
	var transition_table = state_transitions.transition_table
	for state in transition_table.keys():
		var transitions = transition_table[state]
		for event in transitions.keys():
			var target_state = transitions[event]
			hsm.add_transition(state, target_state, event)

	hsm.initialize(self)
	hsm.set_initial_state(idle_state)
	hsm.set_active(true)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact") and is_on_floor() and can_move:
		var actionables = %ActionDetectionArea.get_overlapping_areas().filter(
			func(area): return area is Actionable
		)
		actionables.reverse() # reorders the array: top -> bottom of the scene tree
		if actionables.size() > 0:
			print("actionables: ", actionables)
			var actionable: Actionable = actionables[0]
			actionable.action()
	
	if Input.is_action_just_pressed("combo_charge") and combo_charges > 0:
		combo_charged = true
		combo_charges -= 1
	
	if Input.is_action_just_pressed("debug_unlock_all"):
		PlayerConfig.unlock_all()

func _physics_process(delta: float) -> void:
	if not can_move:
		return
	
	previous_active_state = current_active_state
	current_active_state = hsm.get_active_state().name
	apply_gravity(delta)

	direction = Input.get_axis("move_left", "move_right")

	var facing_direction = 1 if direction > 0 else -1
	if PlayerConfig.facing_direction != facing_direction and direction != 0 and current_active_state not in PlayerConfig.NON_FLIP_SPRITE_STATES and not cannot_turnaround:
		PlayerConfig.facing_direction = facing_direction
		direction_pointer.position.x = facing_direction * 16
		%Sprite2D.flip_h = facing_direction < 0

	handle_frisbee()
	handle_movement(delta)

func clear_frisbee_reference() -> void:
	current_frisbee = null

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

func handle_frisbee():
	if current_frisbee and Input.is_action_pressed("throw_frisbee"):
		current_frisbee.is_throw_button_held = true
	elif current_frisbee:
		current_frisbee.is_throw_button_held = false
	
	if Input.is_action_just_pressed("throw_frisbee") and not current_frisbee:
		if is_on_floor() or PlayerConfig.current_frisbee_throws > 0:
			if not is_on_floor():
				PlayerConfig.current_frisbee_throws -= 1
			animation_player.play("throw_frisbee")
			animation_player.animation_finished.connect(_end_frisbee_throw)
			if not is_on_floor():
				velocity.y = frisbee_throw_velocity
			var frisbee_instance := Utils.spawn(frisbee, global_position + Vector2(15 * PlayerConfig.facing_direction, 2)) as Frisbee
			current_frisbee = frisbee_instance
			frisbee_instance.direction.x = PlayerConfig.facing_direction

func apply_gravity(delta: float):
	if not is_on_floor() and gravity_multiplier > 0.0:
		velocity += get_gravity() * gravity_multiplier * delta
		velocity.y = min(velocity.y, terminal_velocity_y)
	# Note: The bottom is probably the way it "should be," but maintaining the current y velocity on dash feels more fun so far. Leaving this commented for future reference.
	# elif not is_on_floor() and gravity_multiplier == 0.0:
		# velocity.y = 0

func jump():
	if combo == 0 or position.distance_to(last_jump_position) > 80:
		last_jump_position = position
		combo += 1
	if can_boost_jump or combo_charged:
		%FastMovementEffectTimer.start()
		combo_charged = false
		velocity.y = PlayerConfig.jump_velocity * 1.25
	else:
		var has_move_input = Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")
		if can_boost_jump_forward and has_move_input:
			if current_active_state == "AirDashState":
				velocity.x = (air_dash_speed) * PlayerConfig.facing_direction
			else:
				velocity.x = (air_dash_speed / 1.2) * PlayerConfig.facing_direction

		velocity.y = PlayerConfig.jump_velocity

func bounce(bounce_velocity := 0):
	air_state.started_falling = false
	animation_player.play("jump")
	
	velocity.y = PlayerConfig.bounce_velocity if bounce_velocity == 0.0 else bounce_velocity * 1.0
	PlayerConfig.current_frisbee_throws = min(PlayerConfig.current_frisbee_throws + 1, PlayerConfig.max_frisbee_throws)

func set_is_coyote_time(new_value: bool):
	is_coyote_time = new_value
	if new_value != true:
		return
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

func _on_action_detection_area_area_entered(area: Area2D) -> void:
	if area is Unlockable:
		var unlockable: Unlockable = area
		PlayerConfig.unlock_ability(unlockable.unlock_key)
		MetSys.store_object(unlockable)
		unlockable.queue_free()

func create_dash_effect():
	var dash_effect = %Sprite2D.duplicate()
	dash_effect.position = position
	dash_effect.flip_h = %Sprite2D.flip_h
	var tint_color = Color(0.2, 0.2, 1, 0.4)
	dash_effect.modulate = dash_effect.modulate.blend(tint_color)
	get_parent().add_child(dash_effect)


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

func handle_landing() -> void:
	PlayerConfig.current_air_dashes = PlayerConfig.max_air_dashes
	PlayerConfig.current_jumps = PlayerConfig.max_jumps
	PlayerConfig.current_frisbee_throws = PlayerConfig.max_frisbee_throws
	can_bounce = true
	gravity_multiplier = 1.0

func _on_hurtbox_hurt(hitbox: Hitbox) -> void:
	PlayerConfig.health -= hitbox.damage
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

func disable_movement():
	can_move = false
	hsm.set_active(false)

func enable_movement():
	can_move = true
	hsm.set_active(true)

func set_cannot_turnaround(new_val: bool):
	cannot_turnaround = new_val
	await get_tree().create_timer(no_turnaround_timer).timeout
	cannot_turnaround = false

func allow_attack():
	can_attack = true
	%Attack1Cooldown.start()

func _on_combo_timer_timeout() -> void:
	# print("Combo ended!")
	combo = 0
	combo_charges = 0

func reset_to_checkpoint():
	Events.screen_shake.emit(10.0, 0.5)
	Events.player_reset_for_challenge.emit()
	
	position = mid_level_checkpoint_position if mid_level_checkpoint_position else reset_position
	velocity = Vector2.ZERO
	gravity_multiplier = 1.0
	if current_frisbee:
		current_frisbee.queue_free_safely()

func set_combo(new_combo: int):
	if %ComboTimer.time_left:
		%ComboTimer.stop()
	combo = new_combo
	if combo % PlayerConfig.combo_charge_threshold == 0 and combo != 0:
		combo_charges += 1
		# print("Combo charge added! Total: ", combo_charges)
	# print("Combo added to: ", combo)

func _connect_signals():
	Dialogic.signal_event.connect(_on_dialogic_event)
	MetSys.room_changed.connect(_on_room_changed)

func _on_room_changed(_room_name: String) -> void:
	await get_tree().create_timer(0.1).timeout # wait until position updates
	mid_level_checkpoint_position = global_position
	
func _on_dialogic_event(event_name: String) -> void:
	if event_name == "cutscene_ended":
		Utils.handle_cutscene_end()

func _end_frisbee_throw(animation_name: String = ""):
	if animation_name == "throw_frisbee":
		animation_player.play("idle" if is_on_floor() else "jump")
		animation_player.animation_finished.disconnect(_end_frisbee_throw)
