class_name Hitstop
extends Node2D

func _ready() -> void:
    Events.hitstop.connect(_on_hitstop)

func _on_hitstop(duration: float) -> void:
    get_tree().paused = true
    await get_tree().create_timer(duration).timeout
    get_tree().paused = false