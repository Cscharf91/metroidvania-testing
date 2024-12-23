class_name PlayerRespawner
extends Area2D

@export var damage := 10.0

func _ready() -> void:
    body_entered.connect(_on_player_entered)

func _on_player_entered(body: Player) -> void:
    if body is not Player:
        return
    
    PlayerConfig.health -= damage
    body.reset_to_checkpoint()