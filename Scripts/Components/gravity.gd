class_name Gravity
extends Node2D

@onready var body: CharacterBody2D = owner

@export var terminal_velocity_y: float

var gravity_multiplier := 1.0
var is_active := true

func _physics_process(delta: float) -> void:
	if is_active:
		apply_gravity(delta)

func apply_gravity(delta: float):
	if not body.is_on_floor() and gravity_multiplier > 0.0:
		body.velocity += body.get_gravity() * gravity_multiplier * delta
		if terminal_velocity_y:
			body.velocity.y = min(body.velocity.y, terminal_velocity_y)