extends Area2D

@export var next_scene: PackedScene

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.can_move = false
		TransitionLayer.animation_player.play("fade_in")
		await TransitionLayer.animation_player.animation_finished
		get_tree().change_scene_to_packed(next_scene)
		body.can_move = true
		TransitionLayer.animation_player.play("fade_out")
