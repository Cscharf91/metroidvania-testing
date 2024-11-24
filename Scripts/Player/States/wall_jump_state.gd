class_name WallJumpState extends LimboState

@onready var player: Player = owner

var wall_direction_x := 0
var wall_coyote_timer_active := false
var wall_coyote_timer := 0.15
var can_wall_jump := true
var wall_slide_velocity := 80.0

func _enter() -> void:
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
	if Input.is_action_just_pressed("jump") and can_wall_jump or player.jump_buffered:
		perform_wall_jump()
		player.jump_buffered = false
	elif is_touching_wall() and not wall_coyote_timer_active:
		var direction = sign(player.direction)
		var is_holding_towards_wall = direction != 0 and direction == wall_direction_x
		if is_holding_towards_wall:
			player.velocity.y = wall_slide_velocity / 2
		can_wall_jump = true
	elif not wall_coyote_timer_active:
		start_wall_coyote_timer()

	if player.is_on_floor():
		dispatch("landed")
	elif not is_touching_wall() and not wall_coyote_timer_active:
		dispatch("in_air")

	player.move_and_slide()

func perform_wall_jump():
	player.velocity.y = PlayerConfig.jump_velocity
	player.velocity.x = (wall_direction_x * -1) * PlayerConfig.wall_jump_velocity
	can_wall_jump = false
	dispatch("in_air")

func start_wall_coyote_timer():
	wall_coyote_timer_active = true
	print("Coyote start!")
	await get_tree().create_timer(wall_coyote_timer).timeout
	if not is_touching_wall():
		print("Wall coyote time expired")
		can_wall_jump = false
		wall_coyote_timer_active = false
		dispatch("landed" if player.is_on_floor() else "in_air")
	else:
		wall_coyote_timer_active = false
		print("Wall contact regained, coyote timer canceled")

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