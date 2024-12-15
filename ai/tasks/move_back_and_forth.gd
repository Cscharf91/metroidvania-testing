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
	var curr_enemy: Enemy = agent

	if curr_enemy.player_detected and curr_enemy.attacks_player:
		return SUCCESS
	
	if curr_enemy.is_on_wall():
		curr_enemy.reverse_direction()
		return RUNNING
	
	curr_enemy.move_in_direction(curr_enemy.facing_dir)
	return RUNNING
