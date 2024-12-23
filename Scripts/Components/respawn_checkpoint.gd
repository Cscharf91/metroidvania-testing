class_name RespawnCheckpoint
extends Area2D

@export var one_shot := false
var checkpoint_spawn_marker: Marker2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	var children = get_children()
	for child in children:
		if child is Marker2D:
			checkpoint_spawn_marker = child
			break
	body_entered.connect(_on_player_entered)

func _on_player_entered(body: Player) -> void:
	if body is not Player:
		return

	# this area can be large to ensure the player crosses it, so the reset position will have to be the bottom of the area, then up a bit - the player's collision shape height
	body.reset_position = global_position if not checkpoint_spawn_marker else checkpoint_spawn_marker.global_position
	if one_shot:
		queue_free()
