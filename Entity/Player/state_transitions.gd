class_name StateTransitions
extends Node

@onready var idle_state: IdleState = %LimboHSM/IdleState
@onready var move_state: MoveState = %LimboHSM/MoveState
@onready var air_state: AirState = %LimboHSM/AirState
@onready var air_dash_state: AirDashState = %LimboHSM/AirDashState
@onready var ground_pound_state: GroundPoundState = %LimboHSM/GroundPoundState
@onready var landing_state: LandingState = %LimboHSM/LandingState
@onready var wall_jump_state: WallJumpState = %LimboHSM/WallJumpState
@onready var glide_state: GlideState = %LimboHSM/GlideState
@onready var slide_state: SlideState = %LimboHSM/SlideState
@onready var melee_attack1_state: AttackState = %LimboHSM/MeleeAttack1State
@onready var melee_attack2_state: AttackState = %LimboHSM/MeleeAttack2State
@onready var melee_air_attack1_state: AttackState = %LimboHSM/MeleeAirAttack1State
@onready var melee_air_attack2_state: AttackState = %LimboHSM/MeleeAirAttack2State

var transition_table = {}

func _ready() -> void:
	transition_table = {
		air_state: {
			"landed": landing_state,
			"ground_pound_landed": landing_state,
			"air_dash": air_dash_state,
			"ground_pound": ground_pound_state,
			"wall_jump": wall_jump_state,
			"glide": glide_state,
			"melee_air_attack1": melee_air_attack1_state,
			"melee_air_attack2": melee_air_attack2_state,
		},

		air_dash_state: {
			"landed": landing_state,
			"ground_pound_landed": landing_state,
			"in_air": air_state,
			"ground_pound": ground_pound_state,
			"wall_jump": wall_jump_state,
			"glide": glide_state,
		},

		ground_pound_state: {
			"landed": landing_state,
			"ground_pound_landed": landing_state,
			"boosted_air_dash": air_dash_state,
		},

		landing_state: {
			"in_air": air_state,
			"movement_started": move_state,
			"movement_stopped": idle_state,
		},

		idle_state: {
			"in_air": air_state,
			"movement_started": move_state,
			"slide": slide_state,
			"melee_attack1": melee_attack1_state,
			"attack2": melee_attack2_state,
		},

		move_state: {
			"in_air": air_state,
			"movement_stopped": idle_state,
			"slide": slide_state,
			"melee_attack1": melee_attack1_state,
			"melee_attack2": melee_attack2_state,
		},

		slide_state: {
			"in_air": air_state,
			"movement_stopped": idle_state,
			"movement_started": move_state,
		},

		melee_attack1_state: {
			"in_air": air_state,
			"attack_ended": idle_state,
			"movement_started": move_state,
			"melee_attack2": melee_attack2_state,
			"slide": slide_state,
		},

		melee_attack2_state: {
			"in_air": air_state,
			"attack_ended": idle_state,
			"movement_started": move_state,
			"slide": slide_state,
		},

		melee_air_attack1_state: {
			"in_air": air_state,
			"melee_air_attack2": melee_air_attack2_state,
			"landed_melee_attack1": melee_attack1_state,
			"melee_attack2": melee_attack2_state,
		},

		melee_air_attack2_state: {
			"in_air": air_state,
			"landed_melee_attack2": melee_attack2_state,
		},

		glide_state: {
			"in_air": air_state,
			"air_dash": air_dash_state,
			"ground_pound": ground_pound_state,
			"wall_jump": wall_jump_state,
			"landed": landing_state,
		},

		wall_jump_state: {
			"in_air": air_state,
			"landed": landing_state,
		}
	}
