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
		await player.animation_player.animation_finished
		if player.current_active_state == "IdleState":
			player.animation_player.play("idle")
	elif player.animation_player.current_animation != "jump":
		player.animation_player.play("idle")

func _exit() -> void:
	pass

func _update(_delta: float) -> void:
	if !player.can_move:
		dispatch("movement_stopped")
		return
	
	if Input.is_action_just_pressed("jump"):
		PlayerConfig.current_jumps -= 1
		player.jump()
		dispatch("in_air")
	
	if player.is_on_floor() and Input.is_action_just_pressed("ground_pound"):
		dispatch("slide")

	var started_on_floor = player.is_on_floor()
	player.move_and_slide()
	var ended_on_floor = player.is_on_floor()

	if started_on_floor and not ended_on_floor:
		player.is_coyote_time = true

	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		dispatch("movement_started")

func _on_movement_started(_cargo = null) -> bool:
	return false
