extends StaticBody2D

@onready var sword_area: Area2D = $SwordArea
@onready var destroyed_particles: PackedScene = preload("res://Global/emphasize_particles.tscn")

func _ready() -> void:
	sword_area.area_entered.connect(_on_area_entered)
	MetSys.register_storable_object(self, handle_destroyed)


func _on_area_entered(area: Area2D) -> void:
	if area.name == "SwordArea":
		return
	Events.screen_shake.emit(10.0, 0.25)
	var particles = Utils.spawn(destroyed_particles, global_position)
	particles.emitting = true
	MetSys.store_object(self)
	handle_destroyed()

func handle_destroyed() -> void:
	queue_free()
