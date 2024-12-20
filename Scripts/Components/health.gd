class_name Health
extends Node2D

signal died

@export var hurtbox: Hurtbox
@export var max_health: float = 100.0
var current_health: float

func _ready() -> void:
	current_health = max_health
	if hurtbox:
		hurtbox.hurt.connect(_on_hurt)

func _on_hurt(hitbox: Hitbox) -> void:
	current_health -= hitbox.damage
	print("owww, enemy got fucked, curr health: ", current_health)
	if current_health <= 0.0:
		died.emit()
	
	# TODO - knockback component
	# apply_knockback(hitbox.knockback)

	# TODO - invincibility component?
