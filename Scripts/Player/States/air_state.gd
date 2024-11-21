class_name AirState extends LimboState

@onready var player: Player = owner

func _enter() -> void:
	# print("Entering Air State from: ", %LimboHSM.get_previous_active_state().name)
	player.animation_player.play("jump")

func _exit() -> void:
	if player.is_on_floor():
		PlayerConfig.current_air_dashes = PlayerConfig.max_air_dashes
		PlayerConfig.current_jumps = PlayerConfig.max_jumps

func _update(_delta: float) -> void:
	if not player.can_move:
		return
		
	if Input.is_action_just_released("jump") and player.velocity.y < 0:
		player.velocity.y *= 0.5
	
	if Input.is_action_just_pressed("jump") and PlayerConfig.current_jumps > 0:
		player.jump()

	if Input.is_action_just_pressed("air_dash") and PlayerConfig.current_air_dashes > 0:
		dispatch("air_dash")
	
	if Input.is_action_just_pressed("ground_pound") and PlayerConfig.unlocks.ground_pound:
		dispatch("ground_pound")

	player.move_and_slide()

	if player.is_on_floor():
		dispatch("landed")