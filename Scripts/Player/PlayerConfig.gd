extends Node

var health := 100.0: set = set_health
var max_health := 100.0: set = set_max_health
var speed := 200
var max_jumps := 1: set = set_max_jumps
var current_jumps := max_jumps: set = set_current_jumps
var max_air_dashes := 0: set = set_max_air_dashes
var current_air_dashes := max_air_dashes
var acceleration := 1000
var friction := 2100
var jump_velocity := -400
var ground_pound_speed := 2000
var facing_direction := 1
var wall_jump_velocity := 400
var current_checkpoint := Vector2.ZERO
var slide_speed := 300.0
var max_speed := 1000.0
var combo_charge_threshold := 3

const NON_FLIP_SPRITE_STATES = ["GroundPoundState", "AirDashState"]

var abilities: Array[StringName] = []

func unlock_ability(ability: StringName) -> void:
	abilities.append(ability)
	if ability == &"double_jump":
		max_jumps = 2
		current_jumps = max_jumps
	if ability == &"air_dash":
		max_air_dashes = 1
		current_air_dashes = max_air_dashes

func unlock_all() -> void:
	print("unlocking all abilities, sup?")
	var unlockable_abilities = [
		&"double_jump",
		&"air_dash",
		&"wall_jump",
		&"glide",
		&"ground_pound",
		&"slide",
		&"katana_attack",
	]
	for ability in unlockable_abilities:
		unlock_ability(ability)
	
	print("unlocked all abilities")

func set_health(new_health: float) -> void:
	health = max(new_health, 0)
	if health <= 0:
		# TODO - handle death logic
		print("Oh no! U ded!")

func set_max_health(new_max_health: float) -> void:
	max_health = new_max_health

func set_current_jumps(new_jumps: int) -> void:
	current_jumps = clamp(new_jumps, 0, max_jumps)

func set_max_jumps(new_jumps: int) -> void:
	max_jumps = new_jumps
	current_jumps = max_jumps

func set_max_air_dashes(new_air_dashes: int) -> void:
	max_air_dashes = new_air_dashes
	current_air_dashes = max_air_dashes
