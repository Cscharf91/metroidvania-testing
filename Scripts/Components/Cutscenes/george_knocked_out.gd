extends Area2D

var is_walking := true
var is_knocked_out := false
var knockout_timer := 1.0
var knockback_velocity := Vector2(-400, -200)

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if is_walking:
		global_position.x += 50 * delta
	
	if is_knocked_out:
		global_position += knockback_velocity * delta
		rotation_degrees += 725 * delta

func _on_area_entered(_area: Area2D) -> void:
	animated_sprite.play("in_air")
	animation_player.play("blink")
	Events.hitstop.emit(0.1)
	Events.screen_shake.emit(15.0, 0.3)
	is_walking = false
	is_knocked_out = true
	await get_tree().create_timer(knockout_timer).timeout
	queue_free()
