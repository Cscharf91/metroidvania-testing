class_name AirDashState extends LimboState

@onready var player: Player = owner

func _enter() -> void:
	var previous_state = %LimboHSM.get_previous_active_state().name

	# print("Entering Air Dash State from: ", previous_state)
	
	var is_boosted_dash = previous_state == "GroundPoundState"

	var direction = "right" if %Sprite2D.flip_h else "left"
	player.animation_player.play("air_dash_" + str(direction))
	
	air_dash(is_boosted_dash)

func _exit() -> void:
	player.gravity_multiplier = 1.0
	if player.is_on_floor():
		PlayerConfig.current_air_dashes = PlayerConfig.max_air_dashes
		PlayerConfig.current_jumps = PlayerConfig.max_jumps
	
func _update(_delta: float) -> void:
	player.move_and_slide()
	if player.is_on_floor():
		dispatch("landed")
	
	if not player.can_move:
		return

	if Input.is_action_just_pressed("ground_pound") and PlayerConfig.unlocks.ground_pound:
		dispatch("ground_pound")

	if Input.is_action_just_pressed("jump") and PlayerConfig.current_jumps > 0:
		player.can_boost_jump = true
		player.jump()
		dispatch("in_air")

func air_dash(is_boosted: bool) -> void:
	if PlayerConfig.current_air_dashes <= 0:
		return
	
	PlayerConfig.current_air_dashes -= 1
	player.gravity_multiplier = 0.0
	var air_dash_direction = 1 if %Sprite2D.flip_h else -1

	# Directly set velocity.x with respect to direction and terminal velocity
	var dash_tween = create_tween()
	var total_air_dash_speed = player.air_dash_speed if not is_boosted else player.air_dash_speed * 1.2
	dash_tween.tween_property(player, "velocity:x", air_dash_direction * total_air_dash_speed, 0.1)
	dash_tween.connect("finished", _on_dash_tween_completed)

func _on_dash_tween_completed() -> void:
	player.gravity_multiplier = 1.0
