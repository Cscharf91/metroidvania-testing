class_name Hurtbox
extends Area2D

signal hurt(hitbox, damage: float)

var is_invincible = false:
	set(value):
		is_invincible = value
		disable.call_deferred(value)

func hit(hitbox: Hitbox, damage: float) -> void:
	hurt.emit(hitbox, damage)

func disable(value):
	for child in get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.disabled = value