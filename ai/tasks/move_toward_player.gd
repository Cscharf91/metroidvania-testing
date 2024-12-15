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


# Called when the task is executed.
func _tick(_delta: float) -> Status:
	var curr_enemy: Enemy = agent
	var target: Node2D = blackboard.get_var(target_var, null)

	if not curr_enemy.player_detected:
		return FAILURE
	
	if curr_enemy.is_on_wall():
		pass # TODO - logic to potentially jump to continue chase
	
	var x_direction = 1 if target.global_position.x - curr_enemy.global_position.x > 0 else -1

	var distance = curr_enemy.global_position.distance_to(target.global_position)

	if distance <= tolerance:
		return SUCCESS
	
	curr_enemy.move_in_direction(x_direction)
	curr_enemy.face_dir(x_direction)
	return RUNNING
