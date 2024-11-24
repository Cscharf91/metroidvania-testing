class_name LandingState extends LimboState

@onready var player: Player = owner
@onready var ImpactEffect: PackedScene = preload("res://Effects/impact_effect.tscn")

var previous_state := ""
const BOOST_JUMP_STATES = ["GroundPoundState"]
const BOOST_JUMP__FORWARDSTATES = ["AirDashState"]

func _enter() -> void:
	previous_state = %LimboHSM.get_previous_active_state().name
	print("Entering Landing State from: ", previous_state)

	var impact_effect = ImpactEffect.instantiate()
	impact_effect.global_position = player.global_position
	get_parent().add_child(impact_effect)
	impact_effect.emitting = true
	
	PlayerConfig.current_air_dashes = PlayerConfig.max_air_dashes
	PlayerConfig.current_jumps = PlayerConfig.max_jumps - 1 if player.jump_buffered else PlayerConfig.max_jumps
	player.gravity_multiplier = 1.0

	player.can_boost_jump = previous_state in BOOST_JUMP_STATES
	player.can_boost_jump_forward = previous_state in BOOST_JUMP__FORWARDSTATES
	handle_next_state()


func _exit() -> void:
	pass
	
func _update(_delta: float) -> void:
	player.move_and_slide()

func handle_next_state() -> void:
	if Input.is_action_just_pressed("jump") or player.jump_buffered:
		player.jump()
		dispatch("in_air")
	
	if player.direction != 0:
		dispatch("movement_started")
	else:
		dispatch("movement_stopped")
