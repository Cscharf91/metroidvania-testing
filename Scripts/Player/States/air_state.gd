class_name AirState extends LimboState

@onready var player: Player = owner

var previous_state := ""

func _enter() -> void:
	previous_state = %LimboHSM.get_previous_active_state().name
	# print("Entering Air State from: ", previous_state)
	player.animation_player.play("jump")

func _exit() -> void:
	if player.is_on_floor():
		PlayerConfig.current_air_dashes = PlayerConfig.max_air_dashes
		PlayerConfig.current_jumps = PlayerConfig.max_jumps

func _update(_delta: float) -> void:
	if not player.can_move:
		return
		
	# if (
	# 	Input.is_action_just_released("jump")
	# 	and previous_state != "WallJumpState"
	# ):
	# 	player.velocity.y *= 0.5
	
	if Input.is_action_just_pressed("jump") and PlayerConfig.current_jumps > 0:
		print("ello puppet", PlayerConfig.current_jumps)
		PlayerConfig.current_jumps -= 1
		player.jump()
	elif Input.is_action_just_pressed("jump") and PlayerConfig.current_jumps == 0:
		print("yo what gives", PlayerConfig.current_jumps)

	if Input.is_action_just_pressed("air_dash") and PlayerConfig.current_air_dashes > 0:
		dispatch("air_dash")
	
	if Input.is_action_just_pressed("ground_pound") and PlayerConfig.unlocks.ground_pound:
		dispatch("ground_pound")

	player.move_and_slide()

	if player.is_on_floor():
		dispatch("landed")
	
	if player.is_on_wall():
		dispatch("wall_jump")
