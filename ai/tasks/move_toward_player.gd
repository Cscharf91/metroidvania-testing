@tool
extends BTAction

@export var target_var: StringName = &"target"
@export var tolerance: float = 10

func _generate_name() -> String:
	return "MoveTowardTarget"

func _tick(_delta: float) -> Status:
	var enemy_movement: EnemyMovement = agent.find_child("EnemyMovement")
	if not enemy_movement:
		print("No EnemyMovement found on agent in MoveTowardTarget")
		return FAILURE

	var target: Node2D = blackboard.get_var(target_var, null)
	if not target:
		print("No target found in MoveTowardTarget")
		return FAILURE

	# Delegate movement logic to EnemyMovement
	var reached_target = enemy_movement.move_toward_target(target, tolerance)

	if reached_target:
		return SUCCESS

	return RUNNING
	
