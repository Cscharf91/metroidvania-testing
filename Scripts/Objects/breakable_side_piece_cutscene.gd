extends StaticBody2D

@onready var sword_area: Area2D = $SwordArea
@onready var destroyed_particles: PackedScene = preload("res://Global/emphasize_particles.tscn")

func _ready() -> void:
	sword_area.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.name == "SwordArea":
		return
	var particles = Utils.spawn(destroyed_particles, global_position)
	particles.emitting = true
	queue_free()
