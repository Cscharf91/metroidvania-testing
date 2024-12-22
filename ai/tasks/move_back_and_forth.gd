@tool
extends BTAction

func _generate_name() -> String:
	return "MoveBackAndForth"

func _tick(_delta: float) -> Status:
	var enemy_movement: EnemyMovement = agent.find_child("EnemyMovement")
	var player_detection_area: PlayerDetectionArea = agent.find_child("PlayerDetectionArea")
	
	if not enemy_movement:
		print("No EnemyMovement found on agent in MoveBackAndForth")
		return FAILURE
	if not player_detection_area:
		print("No PlayerDetectionArea found on agent in MoveBackAndForth")
		return FAILURE

	if player_detection_area.is_player_detected:
		print("Player detected in MoveBackAndForth")
		return SUCCESS
	
	enemy_movement.patrol()

	return RUNNING
