class_name CollectibleItem
extends Area2D

signal collected(item: CollectibleItem)

@export var collected_sfx: AudioStream
@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var collision_shape: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null
@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D if has_node("AudioStreamPlayer2D") else null

var initial_global_position: Vector2
var initial_visibility: bool
var is_gathered: bool = false

func _ready() -> void:
	if not sprite:
		printerr("CollectibleItem: Sprite2D node not found or not named 'Sprite2D' for ", name)
	if not collision_shape:
		printerr("CollectibleItem: CollisionShape2D node not found or not named 'CollisionShape2D' for ", name)
	if not animation_player:
		printerr("CollectibleItem: AnimationPlayer node not found or not named 'AnimationPlayer' for ", name)
	if not audio_stream_player:
		printerr("CollectibleItem: AudioStreamPlayer2D node not found or not named 'AudioStreamPlayer2D' for ", name)

	initial_global_position = global_position
	initial_visibility = visible
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	if animation_player and animation_player.has_animation("idle"):
		animation_player.play("idle")

func _on_body_entered(body: Node) -> void:
	if is_gathered:
		return

	if body is Player:
		is_gathered = true
		collected.emit(self)
		
		if animation_player and animation_player.has_animation("collected"):
			animation_player.play("collected")
		else:
			visible = false
		
		if audio_stream_player and collected_sfx:
			audio_stream_player.stream = collected_sfx
			audio_stream_player.play()
			
		if collision_shape:
			collision_shape.set_deferred("disabled", true)

func reset_collectible() -> void:
	is_gathered = false
	global_position = initial_global_position
	visible = initial_visibility
	
	if animation_player and animation_player.has_animation("idle"):
		animation_player.play("idle")
	
	if collision_shape:
		collision_shape.set_deferred("disabled", false)