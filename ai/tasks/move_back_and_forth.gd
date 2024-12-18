@tool
extends BTAction
## Moves the agent back and forth, turning around at walls/ledges.

func _generate_name() -> String:
	return "MoveBackAndForth"

# Called to initialize the task.
func _setup() -> void:
	pass

# Called when the task is executed.
func _tick(_delta: float) -> Status:
	var curr_enemy: CharacterBody2D = agent
	var enemy_movement: EnemyMovement = agent.find_child("EnemyMovement")
	var player_detection_area: PlayerDetectionArea = agent.find_child("PlayerDetectionArea")

	if not enemy_movement:
		print("No EnemyMovement found on agent in MoveBackAndForth")
		return FAILURE

	if player_detection_area and player_detection_area.is_player_detected:
		return SUCCESS
	
	if curr_enemy.is_on_wall():
		enemy_movement.reverse_direction()
		return RUNNING
	
	enemy_movement.move_in_direction(enemy_movement.facing_dir)
	return RUNNING
