class_name WallJumpState extends LimboState

@onready var player: Player = owner

var wall_direction_x := 0
var wall_coyote_timer_active := false
var wall_coyote_timer := 0.15
var can_wall_jump := true
var wall_slide_velocity := 80.0
var wall_landed := false

func _enter() -> void:
	wall_landed = false
	can_wall_jump = true
	wall_coyote_timer_active = false

	PlayerConfig.current_air_dashes = PlayerConfig.max_air_dashes
	PlayerConfig.current_jumps = PlayerConfig.max_jumps - 1
	player.gravity_multiplier = 1.0

func _exit() -> void:
	print("Leaving wall jump state")
	can_wall_jump = false
	wall_coyote_timer_active = false

func _update(_delta: float) -> void:
	var direction = sign(player.direction)
	if Input.is_action_just_pressed("jump") and can_wall_jump:
		perform_wall_jump()
	elif is_touching_wall() and not wall_coyote_timer_active:
		var is_holding_towards_wall = direction != 0 and direction == wall_direction_x
		if is_holding_towards_wall and player.velocity.y > 0:
			player.velocity.y = wall_slide_velocity / 2
			if player.animation_player.current_animation != "wall_slide" and player.animation_player.current_animation != "wall_land" and not wall_landed:
				player.animation_player.play("wall_land")

		can_wall_jump = true
	elif not wall_coyote_timer_active:
		start_wall_coyote_timer()
		player.animation_player.play("fall")
	
	var is_holding_away_from_wall = direction != 0 and direction != wall_direction_x
	if is_holding_away_from_wall:
		player.animation_player.play("fall")

	if player.is_on_floor():
		dispatch("landed")
	elif not is_touching_wall() and not wall_coyote_timer_active:
		dispatch("in_air")

	player.move_and_slide()

func perform_wall_jump():
	if not wall_coyote_timer_active:
		player.animation_player.play("jump")
		player.direction = player.direction * -1
		PlayerConfig.facing_direction = PlayerConfig.facing_direction * -1
		%Sprite2D.flip_h = false if %Sprite2D.flip_h else true
		player.cannot_turnaround = true

	player.velocity.y = PlayerConfig.jump_velocity
	player.velocity.x = (wall_direction_x * -1) * PlayerConfig.wall_jump_velocity
	can_wall_jump = false
	dispatch("in_air")

func start_wall_coyote_timer():
	wall_coyote_timer_active = true
	await get_tree().create_timer(wall_coyote_timer).timeout
	if not is_touching_wall():
		can_wall_jump = false
		wall_coyote_timer_active = false
		dispatch("landed" if player.is_on_floor() else "in_air")
	else:
		wall_coyote_timer_active = false

func is_touching_wall() -> bool:
	var collision_margin = 1.0
	var left_vector = Vector2(-collision_margin, 0)
	var right_vector = Vector2(collision_margin, 0)
	
	if player.test_move(player.transform, left_vector):
		wall_direction_x = -1
		return true
	elif player.test_move(player.transform, right_vector):
		wall_direction_x = 1
		return true
	return false

func _on_wall_land_animation_finished() -> void:
	if player.current_active_state == "WallJumpState" and not player.animation_player.current_animation == "wall_slide":
		wall_landed = true
		player.animation_player.play("wall_slide")