class_name Unlockable
extends Area2D

@export var unlock_key: StringName = &""

func _ready() -> void:
	# Register it as storable with marker.
	MetSys.register_storable_object_with_marker(self)
