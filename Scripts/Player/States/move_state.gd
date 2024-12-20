class_name MoveState extends LimboState

@onready var player: Player = owner

var previous_state := ""

func _setup() -> void:
	add_event_handler("movement_stopped", _on_movement_stopped)
	add_event_handler("in_air", _on_in_air)

func _enter() -> void:
	previous_state = %LimboHSM.get_previous_active_state().name

	# print("Entering Move State from: ", previous_state)
	
	if previous_state == "AirDashState":
		player.can_boost_jump = true
	player.animation_player.play("run")

func _exit() -> void:
	pass

func _update(delta: float) -> void:
	if !player.can_move:
		dispatch("movement_stopped")

	
	if not player.is_on_floor() and not player.is_coyote_time:
		dispatch("in_air")
		return
	
	handle_movement(delta)
	
	if InputBuffer.is_action_press_buffered("jump"):
		PlayerConfig.current_jumps -= 1
		player.jump()
		dispatch("in_air")
	
	if player.is_on_floor() and Input.is_action_just_pressed("slide") and &"slide" in PlayerConfig.abilities and not %SlideCooldown.time_left:
		dispatch("slide")
	
	if InputBuffer.is_action_press_buffered("attack") and not %Attack1Cooldown.time_left:
		dispatch("melee_attack1")
		
	var started_on_floor = player.is_on_floor()
	player.move_and_slide()
	var ended_on_floor = player.is_on_floor()

	if started_on_floor and not ended_on_floor and not Input.is_action_pressed("jump"):
		PlayerConfig.current_jumps -= 1
		player.is_coyote_time = true

func handle_movement(_delta: float) -> void:
	if player.velocity.x == 0:
		dispatch("movement_stopped") # Return to idle if fully stopped


func _on_movement_stopped(_cargo = null) -> bool:
	return false

func _on_in_air(_cargo = null):
	return false
