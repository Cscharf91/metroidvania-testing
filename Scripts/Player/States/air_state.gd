class_name AirState extends LimboState

@onready var player: Player = owner

func _enter() -> void:
	print("Entering Air State from: ", %LimboHSM.get_previous_active_state().name)
	player.animation_player.play("jump")

func _exit() -> void:
	pass

func _update(_delta: float) -> void:
	if player.direction != 0:
		%Sprite2D.flip_h = player.direction > 0

	if Input.is_action_just_pressed("air_dash") and PlayerStats.current_air_dashes > 0:
		dispatch("air_dash")
	
	if Input.is_action_just_pressed("ground_pound"):
		dispatch("ground_pound")

	player.move_and_slide()

	if player.is_on_floor():
		if player.direction != 0:
			dispatch("movement_started")
		else:
			dispatch("movement_stopped")