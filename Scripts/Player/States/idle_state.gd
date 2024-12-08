class_name IdleState extends LimboState

@onready var player: Player = owner

var previous_state := ""

func _setup() -> void:
	add_event_handler("movement_started", _on_movement_started)

func _enter() -> void:
	previous_state = %LimboHSM.get_previous_active_state().name if %LimboHSM.get_previous_active_state() else ""

	if previous_state == "AirDashState":
		player.can_boost_jump = true

	# print("Entering Idle State from: ", previous_state)

	if previous_state == "GroundPoundState":
		player.gravity_multiplier = 1.0

	if player.animation_player.current_animation == "land":
		if player.animation_player.current_animation == "land" and player.velocity.x != 0:
			player.animation_player.play("run")
			return
		await player.animation_player.animation_finished
		if player.current_active_state == "IdleState":
			player.animation_player.play("idle")
	elif player.animation_player.current_animation != "jump":
		player.animation_player.play("idle" if player.velocity.x == 0 else "run")

func _exit() -> void:
	pass

func _update(_delta: float) -> void:
	if !player.can_move:
		player.animation_player.play("idle")
		player.velocity.x = 0
		dispatch("movement_stopped")
		return
	
	if player.velocity.x == 0 and player.is_on_floor() and player.animation_player.current_animation == "run":
		player.animation_player.play("idle")
	
	if InputBuffer.is_action_press_buffered("jump"):
		PlayerConfig.current_jumps -= 1
		player.jump()
		dispatch("in_air")
	
	if player.is_on_floor() and Input.is_action_just_pressed("ground_pound") and &"slide" in PlayerConfig.abilities and not %SlideCooldown.time_left:
		dispatch("slide")

	var started_on_floor = player.is_on_floor()
	player.move_and_slide()
	var ended_on_floor = player.is_on_floor()

	if started_on_floor and not ended_on_floor:
		player.is_coyote_time = true

	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		dispatch("movement_started")
	
	if InputBuffer.is_action_press_buffered("attack"):
		dispatch("melee_attack1")

func _on_movement_started(_cargo = null) -> bool:
	return false
