class_name AirDashState extends LimboState

@onready var player: Player = owner
var leave_state_timer := 0.5
var active_tween: Tween

func _enter() -> void:
	var previous_state = %LimboHSM.get_previous_active_state().name

	# print("Entering Air Dash State from: ", previous_state)
	 
	var is_boosted_dash = previous_state == "GroundPoundState"

	player.animation_player.play("air_dash")
	
	air_dash(is_boosted_dash)
	%FastMovementEffectTimer.start()

func _exit() -> void:
	if active_tween:
		active_tween.kill()
		active_tween = null
	player.gravity_multiplier = 1.0
	if player.is_on_floor():
		PlayerConfig.current_air_dashes = PlayerConfig.max_air_dashes
		PlayerConfig.current_jumps = PlayerConfig.max_jumps
	%FastMovementEffectTimer.stop()
	
func _update(_delta: float) -> void:
	player.move_and_slide()
	if player.is_on_floor():
		dispatch("landed")
	
	if not player.can_move:
		return

	if Input.is_action_pressed("glide") and &"glide" in PlayerConfig.abilities:
		dispatch("glide")
	
	if Input.is_action_just_pressed("ground_pound") and &"ground_pound" in PlayerConfig.abilities:
		dispatch("ground_pound")

	if InputBuffer.is_action_press_buffered("jump") and PlayerConfig.current_jumps > 0:
		player.can_boost_jump_forward = true
		PlayerConfig.current_jumps -= 1
		player.jump()
		dispatch("in_air")
	
	if player.is_on_wall() and &"wall_jump" in PlayerConfig.abilities:
		dispatch("wall_jump")

func air_dash(is_boosted: bool) -> void:
	if PlayerConfig.current_air_dashes <= 0:
		return
	
	PlayerConfig.current_air_dashes -= 1
	player.gravity_multiplier = 0.0

	# Directly set velocity.x with respect to direction and terminal velocity
	var dash_tween = create_tween()
	active_tween = dash_tween
	var total_air_dash_speed = player.air_dash_speed if not is_boosted else player.air_dash_speed * 2
	dash_tween.tween_property(player, "velocity:x", PlayerConfig.facing_direction * total_air_dash_speed, 0.1)
	if is_boosted:
		dash_tween.tween_property(player, "velocity:y", player.terminal_velocity_y / 1.5, 0.05)
	dash_tween.connect("finished", _on_dash_tween_completed)

func _on_dash_tween_completed() -> void:
	player.gravity_multiplier = 1.0
	await get_tree().create_timer(leave_state_timer).timeout
	if not player.is_on_floor():
		dispatch("in_air")
