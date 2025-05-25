class_name AirState extends LimboState

@onready var player: Player = owner

var previous_state := ""
var started_falling := false

func _enter() -> void:
	previous_state = %LimboHSM.get_previous_active_state().name
	# print("Entering Air State from: ", previous_state)
	player.animation_player.play("jump" if not player.can_boost_jump_forward else "air_dash")
	if player.can_boost_jump_forward:
		%FastMovementEffectTimer.start()

func _exit() -> void:
	started_falling = false
	if player.is_on_floor():
		PlayerConfig.current_air_dashes = PlayerConfig.max_air_dashes
		PlayerConfig.current_jumps = PlayerConfig.max_jumps
		%FastMovementEffectTimer.stop()

func _update(_delta: float) -> void:
	if not player.can_move:
		return
		
	if (
		Input.is_action_just_released("jump")
		and player.velocity.y < 0
		and previous_state != "WallJumpState"
	):
		player.velocity.y *= 0.5
	
	if player.velocity.y >= 0 and not started_falling:
		if player.animation_player.current_animation != "fall" and not started_falling:
			%FastMovementEffectTimer.stop()
			player.fall_start_position = player.global_position
			player.animation_player.play("fall")
		started_falling = true
	
	if Input.is_action_just_pressed("jump") and PlayerConfig.current_jumps > 0:
		started_falling = false
		player.animation_player.play("jump" if not player.can_boost_jump_forward else "air_dash")
		PlayerConfig.current_jumps -= 1
		player.jump()
		# player.do_sick_flip()

	if Input.is_action_just_pressed("air_dash") and PlayerConfig.current_air_dashes > 0:
		dispatch("air_dash")
	
	if Input.is_action_just_pressed("ground_pound") and &"ground_pound" in PlayerConfig.abilities:
		dispatch("ground_pound")

	if Input.is_action_pressed("glide") and &"glide" in PlayerConfig.abilities:
		dispatch("glide")
	
	if (
		InputBuffer.is_action_press_buffered("attack")
		and PlayerConfig.abilities.has("katana_attack")
		and player.can_attack
		and not %Attack1Cooldown.time_left
	):
		dispatch("melee_air_attack1")

	player.move_and_slide()

	if player.is_on_floor():
		dispatch("landed")
	
	if player.is_on_wall() and &"wall_jump" in PlayerConfig.abilities:
		dispatch("wall_jump")
