class_name GroundPoundState extends LimboState

@onready var player: Player = owner
var active_tween: Tween = null

func _enter() -> void:
	# print("Entering Ground Pound State from: ", %LimboHSM.get_previous_active_state().name)
	ground_pound()
	player.can_move = false

func _exit() -> void:
	player.can_move = true
	if active_tween:
		active_tween.stop()
		active_tween = null
	%Sprite2D.scale = Vector2.ONE
	%Sprite2D.rotation_degrees = 0

func _update(_delta: float) -> void:
	if Input.is_action_just_pressed("air_dash") and PlayerConfig.current_air_dashes > 0:
		dispatch("boosted_air_dash")
	
	player.move_and_slide()

	if player.is_on_floor():
			dispatch("ground_pound_landed")

func ground_pound():
	var spin_direction = -1 if %Sprite2D.flip_h else 1
	player.velocity = Vector2.ZERO
	player.gravity_multiplier = 0.0

	active_tween = create_tween()
	active_tween.tween_property(%Sprite2D, "rotation_degrees", %Sprite2D.rotation_degrees + 360 * spin_direction, 0.25)
	active_tween.connect("finished", _on_ground_pound_spin_completed)

func _on_ground_pound_spin_completed():
	active_tween = create_tween()
	# Set to ease in and out
	active_tween.tween_property(%Sprite2D, "scale", Vector2(0.6, 1.3), 0.05)
	%Sprite2D.rotation_degrees = 0
	player.gravity_multiplier = 5.0
	player.velocity.y = PlayerConfig.ground_pound_speed
