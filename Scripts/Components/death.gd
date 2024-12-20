class_name Death
extends AnimationPlayer

@export var health: Health
@export var hitbox: Hitbox
@export var hurtbox: Hurtbox

func _ready() -> void:
	if health:
		health.died.connect(_on_died)
	else:
		print("Death component requires a Health component to function properly")
	animation_finished.connect(_on_animation_finished)

func _on_died() -> void:
	if hitbox:
		_disable_collision_shapes(hitbox)
	if hurtbox:
		_disable_collision_shapes(hurtbox)
		
	if has_animation("death"):
		play("death")
	else:
		owner.queue_free()

func _on_animation_finished() -> void:
	queue_free()

func _disable_collision_shapes(area: Area2D) -> void:
	for child in area.get_children():
		if child is CollisionShape2D or child is CollisionPolygon2D:
			child.set_deferred("disabled", true)
