extends Node

func spawn(scene: PackedScene, position: Vector2) -> Node2D:
	var instance := scene.instantiate()
	instance.global_position = position
	get_parent().add_child(instance)
	return instance
