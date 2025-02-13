class_name SlideState extends LimboState

@onready var player: Player = owner

var is_sliding_under_platform := false
var dash_ended_while_under_platform := false

func _enter() -> void:
	# var previous_state = %LimboHSM.get_previous_active_state().name
	# print("Entering Slide State from: ", previous_state)

	player.animation_player.play("slide")
	if not player.animation_player.is_connected("animation_finished", _on_animation_finished):
		player.animation_player.connect("animation_finished", _on_animation_finished)
	
	%CollisionShape2D.shape.size = Vector2(10, 10)
	%CollisionShape2D.position = Vector2(0, 11)

	%FastMovementEffectTimer.start()

func _exit() -> void:
	if player.animation_player.is_connected("animation_finished", _on_animation_finished):
		player.animation_player.disconnect("animation_finished", _on_animation_finished)
	
	player.sprite.rotation_degrees = 0
	%CollisionShape2D.shape.size = Vector2(10, 20)
	%CollisionShape2D.position = Vector2(0, 6)
	%FastMovementEffectTimer.stop()
	%SlideCooldown.start()
	
func _update(_delta: float) -> void:
	check_for_overhead_platform()
	handle_slopes()
	if PlayerConfig.facing_direction == 1 and player.velocity.x >= PlayerConfig.slide_speed or PlayerConfig.facing_direction == -1 and player.velocity.x <= -PlayerConfig.slide_speed:
		player.velocity.x = lerp(player.velocity.x, PlayerConfig.slide_speed * PlayerConfig.facing_direction, 0.1)
	else:
		player.velocity.x = PlayerConfig.slide_speed * PlayerConfig.facing_direction
	
	var started_on_floor = player.is_on_floor()
	player.move_and_slide()
	var ended_on_floor = player.is_on_floor()

	if started_on_floor and not ended_on_floor:
		player.is_coyote_time = true
	
	if not player.can_move:
		return
	
	if not is_sliding_under_platform and dash_ended_while_under_platform:
		dispatch("movement_stopped" if player.direction == 0 else "movement_started")
		dash_ended_while_under_platform = false

	if Input.is_action_just_pressed("jump") and PlayerConfig.current_jumps > 0 and not is_sliding_under_platform:
		player.can_boost_jump_forward = true
		PlayerConfig.current_jumps -= 1
		player.jump()
		dispatch("in_air")
	
	if Input.is_action_just_released("ground_pound") and not is_sliding_under_platform:
		dispatch("movement_stopped" if player.direction == 0 else "movement_started")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "slide":
		if is_sliding_under_platform:
			dash_ended_while_under_platform = true
		else:
			dispatch("movement_stopped" if player.direction == 0 else "movement_started")
		
func check_for_overhead_platform() -> void:
	if %OverheadPlatformDetector and %OverheadPlatformDetector.is_colliding():
		print("Sliding under platform")
		is_sliding_under_platform = true
	else:
		is_sliding_under_platform = false
		if dash_ended_while_under_platform:
			print("Sliding out from under platform")
			
func handle_slopes() -> void:
	if player.is_on_wall_only() or not player.is_on_floor():
		return
	
	var floor_angle = player.get_floor_angle()
	var floor_normal = player.get_floor_normal()

	if floor_normal.x > 0:
		player.sprite.rotation = floor_angle
	else:
		player.sprite.rotation = -floor_angle
