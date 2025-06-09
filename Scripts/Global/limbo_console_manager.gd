extends Node2D

func _ready() -> void:
	LimboConsole.register_command(teleport, "teleport", "Teleport to a room")
	LimboConsole.register_command(unlock_ability, "unlock_ability", "Unlock an ability")

func teleport(target_map: String, x: int, y: int) -> void:
	Game.get_singleton().load_room(target_map)
	Game.get_singleton().reset_map_starting_coords()
	PlayerConfig.get_player().global_position = Vector2(x, y)

func unlock_ability(ability: String) -> void:
	PlayerConfig.unlock_ability(ability)