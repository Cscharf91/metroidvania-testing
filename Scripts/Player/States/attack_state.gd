class_name AttackState extends LimboState

@onready var player: Player = owner

var previous_state := ""

@export var damage := 5
@export var next_state_dispatch: String
@export var animation: String
@export var is_air_attack := false

func _enter() -> void:
	%Attack1Cooldown.stop()
	player.can_attack = false
	if is_air_attack:
		pass
		#if player.velocity.y < 0:
			#player.velocity.y = 0
	
	previous_state = %LimboHSM.get_previous_active_state().name
	# print("Entering Attack State from: ", previous_state)

	var skip_animation = previous_state.begins_with("MeleeAirAttack") and is_air_attack == false
	if not skip_animation:
		player.animation_player.play(animation)
	
	if not player.animation_player.is_connected("animation_finished", _on_animation_finished):
		player.animation_player.connect("animation_finished", _on_animation_finished)
  
func _exit() -> void:
	print("leaving this attack state: ", animation)
	player.gravity_multiplier = 1.0
	player.can_attack = true
	if player.animation_player.is_connected("animation_finished", _on_animation_finished):
		player.animation_player.disconnect("animation_finished", _on_animation_finished)

func _update(_delta: float) -> void:
	if not player.can_attack and player.is_on_floor():
		player.velocity = Vector2(0, player.velocity.y)
	if InputBuffer.is_action_press_buffered("attack") and player.can_attack and next_state_dispatch != "":
		dispatch(next_state_dispatch)
	if not player.is_on_floor() and not player.is_coyote_time and not is_air_attack:
		player.animation_player.stop()
		dispatch("in_air")
		return
  
	if InputBuffer.is_action_press_buffered("jump") and player.can_attack and not is_air_attack:
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
	
	if is_air_attack and player.is_on_floor():
		# Align the current frame with ground attack animation
		var frame = player.animation_player.get_current_animation_position()
		var new_animation = animation.replace("air_", "")
		player.animation_player.play(new_animation)
		player.animation_player.seek(frame, true) # Sync frame
		
		var new_dispatch = "landed_melee_attack" + ("1" if animation.ends_with("1") else "2")
		dispatch(new_dispatch)
		return

func _on_animation_finished(_anim_name: String) -> void:
	if player.is_on_floor():
		player.animation_player.play("idle")
	
	dispatch("attack_ended" if not is_air_attack else "in_air")
	return
