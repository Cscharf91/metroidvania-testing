class_name IdleState extends LimboState

@onready var player: Player = owner

func _setup() -> void:
	add_event_handler("movement_started", _on_movement_started)

func _enter() -> void:
	print("Entering Idle State from: ", %LimboHSM.get_previous_active_state().name if %LimboHSM.get_previous_active_state() else "None")
	player.animation_player.play("idle")

func _exit() -> void:
	pass

func _update(_delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		player.jump()
		dispatch("in_air")

	player.move_and_slide()


	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		dispatch("movement_started")

func _on_movement_started(_cargo = null) -> bool:
	return false
