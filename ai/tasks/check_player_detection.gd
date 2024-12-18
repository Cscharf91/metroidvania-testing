@tool
extends BTAction
## Moves the agent back and forth.

# Called to generate a display name for the task.
func _generate_name() -> String:
	return "MoveBackAndForth"


# Called to initialize the task.
func _setup() -> void:
	pass


# Called when the task is executed.
func _tick(_delta: float) -> Status:
	var curr_enemy: CharacterBody2D = agent

	if curr_enemy.player_detected:
		return FAILURE
	
	if curr_enemy.is_on_wall():
		curr_enemy.turnaround()
		return RUNNING
	
	curr_enemy.move_in_direction(curr_enemy.default_sprite_dir)
	return RUNNING
