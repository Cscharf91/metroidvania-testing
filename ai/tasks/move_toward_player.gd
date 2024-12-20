@tool
extends BTAction
## Moves the agent back and forth, turning around at walls.

@export var target_var: StringName = &"target"
@export var tolerance: float = 10

func _generate_name() -> String:
	return "MoveTowardTarget"


# Called to initialize the task.
func _setup() -> void:
	pass


var _current_facing: int
func _tick(_delta: float) -> Status:
	var curr_enemy: CharacterBody2D = agent
	var enemy_movement: EnemyMovement = agent.find_child("EnemyMovement")
	var orientation: EnemyOrientation = agent.find_child("EnemyOrientation")
	var player_detection_area: PlayerDetectionArea = agent.find_child("PlayerDetectionArea")

	if not enemy_movement:
		print("No EnemyMovement found on agent in MoveTowardTarget")
		return FAILURE
	
	if not _current_facing:
		_current_facing = orientation.default_sprite_dir
	var target: Node2D = blackboard.get_var(target_var, null)

	if not player_detection_area.player_detected:
		return FAILURE

	# Check player's position relative to the enemy
	var x_direction = 1 if target.global_position.x - curr_enemy.global_position.x > 0 else -1

	# If the player moves to the other side of the enemy, reverse direction
	if _current_facing != x_direction:
		enemy_movement.reverse_direction()
		_current_facing = x_direction
		return RUNNING  # Reorient and continue pursuing

	# Handle ledge detection
	if enemy_movement.check_for_ledge():
		return RUNNING  # Stop at ledge but don't fail

	# Handle wall collision
	if curr_enemy.is_on_wall():
		enemy_movement.reverse_direction()
		_current_facing *= -1
		return RUNNING

	# Move toward the player
	var distance = curr_enemy.global_position.distance_to(target.global_position)

	if distance <= tolerance:
		return SUCCESS

	enemy_movement.move_in_direction(x_direction)
	return RUNNING
