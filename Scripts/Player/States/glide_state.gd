class_name GlideState
extends LimboState

@onready var player: Player = owner
var glide_gravity_multiplier := 0.15

func _enter() -> void:
	print("Entering Glide State from: ", %LimboHSM.get_previous_active_state().name)
	# TODO - glide animation
	# player.animation_player.play("glide")

func _exit() -> void:
	player.gravity_multiplier = 1.0

func _update(_delta: float) -> void:
	if player.velocity.y < 0:
		# Moving upwards - apply normal gravity
		player.gravity_multiplier = 1.0
	else:
		# Moving downwards - apply reduced gravity
		player.gravity_multiplier = glide_gravity_multiplier
	
	if Input.is_action_just_released("glide"):
		dispatch("in_air" if not player.is_on_floor() else "landed")
	
	if player.is_on_floor():
		dispatch("landed")
		
	if player.is_on_wall() and &"wall_jump" in PlayerConfig.abilities:
		dispatch("wall_jump")
	
	player.move_and_slide()

	if Input.is_action_just_pressed("ground_pound") and &"ground_pound" in PlayerConfig.abilities:
		dispatch("ground_pound")
	
	if Input.is_action_just_pressed("jump") and PlayerConfig.current_jumps > 0:
		PlayerConfig.current_jumps -= 1
		player.jump()
		dispatch("in_air")
	
	if Input.is_action_just_pressed("air_dash") and PlayerConfig.current_air_dashes > 0:
		dispatch("air_dash")