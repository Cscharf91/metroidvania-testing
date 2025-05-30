extends CutsceneMovingProp

func _on_area_entered(_area: Area2D) -> void:
	animated_sprite_2d.modulate.a = 0
	var player = PlayerConfig.get_player()
	if player:
		player.animation_player.play("throw_frisbee")
		if not player.animation_player.animation_finished.is_connected(_on_animation_finished):
			player.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func _on_animation_finished(animation_name: StringName) -> void:
	var player = PlayerConfig.get_player()
	if player and animation_name == "throw_frisbee":
		player.animation_player.play("idle")
	queue_free()
