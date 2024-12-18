class_name Hitbox
extends Area2D

@export var damage := 10.0
@export var knockback := Vector2(0, 0)

func _ready() -> void:
	connect("area_entered", _on_area_entered)

func _on_area_entered(area: Hurtbox) -> void:
	if area is not Hurtbox or area.owner == self.owner:
		return
	area.hit(self)
