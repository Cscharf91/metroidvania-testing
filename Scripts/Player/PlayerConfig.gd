extends Node

var health := 100.0: set = set_health
var max_health := 100.0: set = set_max_health
var speed := 300
var max_jumps := 1: set = set_max_jumps
var current_jumps := max_jumps: set = set_current_jumps
var max_air_dashes := 0: set = set_max_air_dashes
var current_air_dashes := max_air_dashes: set = set_current_air_dashes
var acceleration := 700
var friction := 2100
var jump_velocity := -400
var ground_pound_speed := 2000
var facing_direction := 1
var wall_jump_velocity := 400

const NON_FLIP_SPRITE_STATES = ["GroundPoundState", "AirDashState"]

var unlocks := {
	"ground_pound": false,
	"air_dash_1": false,
	"air_dash_2": false,
	"mid_air_jump_1": false,
	"wall_jump": false,
}

func unlock_ability(ability: String) -> void:
	if ability in unlocks:
		unlocks[ability] = true
		if ability.begins_with("air_dash"):
			max_air_dashes += 1
		elif ability.begins_with("mid_air_jump"):
			max_jumps += 1

func set_health(new_health: float) -> void:
	health = clamp(new_health, 0, max_health)
	if health <= 0:
		# Player is dead
		pass

func set_max_health(new_max_health: float) -> void:
	max_health = new_max_health

func set_current_air_dashes(new_air_dashes: int) -> void:
	current_air_dashes = clamp(new_air_dashes, 0, max_air_dashes)

func set_current_jumps(new_jumps: int) -> void:
	current_jumps = clamp(new_jumps, 0, max_jumps)

func set_max_jumps(new_jumps: int) -> void:
	max_jumps = new_jumps
	current_jumps = max_jumps

func set_max_air_dashes(new_air_dashes: int) -> void:
	max_air_dashes = new_air_dashes
	current_air_dashes = max_air_dashes

func get_player_config_save_data():
	return {
		"max_health": max_health,
		"max_jumps": max_jumps,
		"max_air_dashes": max_air_dashes,
		"jump_velocity": jump_velocity,
		"speed": speed,
		"unlocks": unlocks,
	}