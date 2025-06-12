class_name Bounce
extends Area2D

@export var bounce_velocity: float = 0.0
@export var animation_player: AnimationPlayer

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if body is Player:
        if animation_player and animation_player.has_animation("bounce"):
            animation_player.play("bounce")
        
        var current_bounce_velocity = bounce_velocity if bounce_velocity > 0 else PlayerConfig.bounce_velocity
        body.bounce(current_bounce_velocity)
        body.handle_air_reset()