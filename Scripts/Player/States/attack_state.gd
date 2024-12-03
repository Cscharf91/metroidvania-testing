class_name AttackState extends LimboState

@onready var player: Player = owner

var previous_state := ""

func _enter() -> void:
	player.can_move = false
	previous_state = %LimboHSM.get_previous_active_state().name

	# print("Entering Attack State from: ", previous_state)
  
func _exit() -> void:
	player.can_move = true

func _update(delta: float) -> void:
	player.velocity = lerp(player.velocity, Vector2(0, 0), 0.1)
	if not player.is_on_floor() and not player.is_coyote_time:
		dispatch("in_air")
		return
  
	handle_movement(delta)
  
	if Input.is_action_just_pressed("jump"):
		PlayerConfig.current_jumps -= 1
		player.jump()
		dispatch("in_air")
  
	if player.is_on_floor() and Input.is_action_just_pressed("ground_pound"):
		dispatch("slide")
	
	var started_on_floor = player.is_on_floor()
	player.move_and_slide()
	var ended_on_floor = player.is_on_floor()

	if started_on_floor and not ended_on_floor and not Input.is_action_pressed("jump"):
		PlayerConfig.current_jumps -= 1
		player.is_coyote_time = true

func handle_movement(_delta: float) -> void:
	if player.velocity.x == 0:
		dispatch("movement_stopped") # Return to idle if fully stopped
