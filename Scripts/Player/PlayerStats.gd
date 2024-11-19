extends Node

var health := 100: set = set_health
var max_health := 100: set = set_max_health
var speed := 300
var max_jumps := 1
var current_jumps := max_jumps: set = set_current_jumps
var max_air_dashes := 1
var current_air_dashes := max_air_dashes: set = set_current_air_dashes
var acceleration := 700
var friction := 1100
var jump_velocity := -400
var ground_pound_speed := 2000

var unlocks := {
	"ground_pound": true
}

func unlock_ability(ability: String) -> void:
	if ability in unlocks:
		unlocks[ability] = true

func set_health(new_health: int) -> void:
	health = clamp(new_health, 0, max_health)
	if health <= 0:
		# Player is dead
		pass

func set_max_health(new_max_health: int) -> void:
	max_health = new_max_health

func set_current_air_dashes(new_air_dashes: int) -> void:
	current_air_dashes = clamp(new_air_dashes, 0, max_air_dashes)

func set_current_jumps(new_jumps: int) -> void:
	current_jumps = clamp(new_jumps, 0, max_jumps)