class_name LandingState extends LimboState

@onready var player: Player = owner
@onready var ImpactEffect: PackedScene = preload("res://Effects/impact_effect.tscn")

var previous_state := ""
const BOOST_JUMP_STATES = ["GroundPoundState"]
const BOOST_JUMP__FORWARDSTATES = ["AirDashState"]

func _enter() -> void:
	player.animation_player.play("land")
	previous_state = %LimboHSM.get_previous_active_state().name
	if player.combo > 0:
		%ComboTimer.start()
	print("Entering Landing State from: ", previous_state)

	var impact_effect = ImpactEffect.instantiate()
	impact_effect.global_position = player.global_position
	get_parent().add_child(impact_effect)
	impact_effect.emitting = true
	
	%Sprite2D.scale = Vector2(1.0, 1.0)
	%Sprite2D.rotation_degrees = 0.0
	PlayerConfig.current_air_dashes = PlayerConfig.max_air_dashes
	PlayerConfig.current_jumps = PlayerConfig.max_jumps
	player.gravity_multiplier = 1.0

	player.can_boost_jump = previous_state in BOOST_JUMP_STATES
	player.can_boost_jump_forward = previous_state in BOOST_JUMP__FORWARDSTATES
	handle_next_state()


func _exit() -> void:
	pass
	
func _update(_delta: float) -> void:
	player.move_and_slide()

func handle_next_state() -> void:
	if InputBuffer.is_action_press_buffered("jump"):
		PlayerConfig.current_jumps -= 1
		player.jump()
		dispatch("in_air")
	
	if player.direction != 0:
		dispatch("movement_started")
	else:
		dispatch("movement_stopped")
