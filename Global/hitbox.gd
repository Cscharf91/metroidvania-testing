class_name Hitbox
extends Area2D


@export var damage := 10.0

func _on_area_entered(area: Hurtbox) -> void:
    if area is not Hurtbox:
        return
    print("Hitbox hit Hurtbox")
    area.hit(self, damage)