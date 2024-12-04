class_name AttackState extends LimboState

@onready var player: Player = owner

var previous_state := ""

@export var damage := 5
@export var next_state_dispatch: String
@export var animation: String

func _enter() -> void:
	player.can_attack = false
	previous_state = %LimboHSM.get_previous_active_state().name
	# print("Entering Attack State from: ", previous_state)

	player.animation_player.play(animation)
	if not player.animation_player.is_connected("animation_finished", _on_animation_finished):
		player.animation_player.connect("animation_finished", _on_animation_finished)
  
func _exit() -> void:
	player.can_attack = true
	player.animation_player.stop()

func _update(_delta: float) -> void:
	if not player.can_attack:
		player.velocity = Vector2(0, player.velocity.y)
	if InputBuffer.is_action_press_buffered("attack") and player.can_attack and next_state_dispatch != "":
		dispatch(next_state_dispatch)
	if not player.is_on_floor() and not player.is_coyote_time:
		player.animation_player.stop()
		dispatch("in_air")
		return
  
	if InputBuffer.is_action_press_buffered("jump") and player.can_attack:
		dispatch("in_air")
  
	if player.is_on_floor() and InputBuffer.is_action_press_buffered("ground_pound") and player.can_attack:
		dispatch("slide")
	
	if player.direction != 0 and player.can_attack:
		dispatch("movement_started")
	
	var started_on_floor = player.is_on_floor()
	player.move_and_slide()
	var ended_on_floor = player.is_on_floor()

	if started_on_floor and not ended_on_floor and not InputBuffer.is_action_press_buffered("jump"):
		PlayerConfig.current_jumps -= 1
		player.is_coyote_time = true

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == animation:
		dispatch("attack_ended")
		return