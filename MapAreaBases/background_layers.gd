extends Node


func _ready() -> void:
	for node in get_children():
		node.z_index = -99
		node.visible = true