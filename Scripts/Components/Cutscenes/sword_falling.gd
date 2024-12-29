extends Area2D

@export var sword_stop_time := 2

var is_falling := false
var is_blown_by_wind := false
var player: Player

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var camera: PhantomCamera2D = $PhantomCamera2D
@onready var wind: PackedScene = preload("res://Objects/wind.tscn")
@onready var george: PackedScene = preload("res://Entity/NPCs/george_knocked_out.tscn")

func _ready() -> void:
	player = PlayerConfig.get_player()
	if not player:
		print("Player not found in: ", name)
	sprite.visible = false
	Dialogic.signal_event.connect(_on_dialogic_event)
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if is_falling:
		global_position.y += 400 * delta
		sprite.rotation_degrees += 725 * delta
		collision_shape.rotation_degrees += 725 * delta
	if is_blown_by_wind:
		global_position.x -= 300 * delta
		sprite.rotation_degrees -= 725 * delta
		collision_shape.rotation_degrees -= 725 * delta
	
func _on_dialogic_event(event_name: String) -> void:
	if event_name == "sword_falling":
		global_position = player.global_position + Vector2(5, -1000)
		camera.priority = 2
		is_falling = true
		sprite.visible = true

func _on_area_entered(area: Area2D) -> void:
	match area.name:
		"SwordSlower":
			area.queue_free()
			player.animation_player.play("reaching_up")
			camera.zoom = Vector2(5, 5)
			Engine.time_scale = 0.05
			return
		"SwordStopper":
			area.queue_free()
			camera.zoom = Vector2(11, 11)
			is_falling = false
			Engine.time_scale = 1.0
			var wind_instance = Utils.spawn(wind, player.global_position + Vector2(20, -15))
			await get_tree().create_timer(sword_stop_time).timeout
			Utils.spawn(george, player.global_position - Vector2(650, 0))
			wind_instance.queue_free()
			player.animation_player.play("idle")
			camera.zoom = Vector2(3, 3)
			await get_tree().create_timer(0.1).timeout
			is_blown_by_wind = true
			return
		"SwordArea":
			await get_tree().create_timer(0.5).timeout
			queue_free()
			return
