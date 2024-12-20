class_name Hitbox
extends Area2D

@export var damage := 10.0
@export var knockback := Vector2(0, 0)
@export var screenshake_amplitude := 10.0
@export var screenshake_duration := 0.05

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Hurtbox) -> void:
	if area is not Hurtbox or area.owner == self.owner:
		return
	area.hit(self)
	if screenshake_amplitude > 0.0 and screenshake_duration > 0.0:
		Events.screen_shake.emit(screenshake_amplitude, screenshake_duration)
