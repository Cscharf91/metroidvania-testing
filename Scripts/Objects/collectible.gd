class_name Collectible
extends Area2D

@export var type: CollectibleType

func _ready() -> void:
	# Register as storable with a marker. The marker will appear on the map when the orb is first discovered (i.e. get instantiated).
	MetSys.register_storable_object_with_marker(self)
	body_entered.connect(collect)

func collect(body: Node2D) -> void:
	print(name + ": Collected by " + body.name)
	if body is not Player:
		return
	# Increase collectible counter.
	Game.get_singleton().collect(type.name)
	# Store the orb. This will automatically assign the collected marker.
	MetSys.store_object(self)
	# Storing object does not free it automatically.
	queue_free()

# func _handle_already_collected() -> void:
# 	queue_free()
