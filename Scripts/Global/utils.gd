extends Node

func spawn(scene: PackedScene, position: Vector2) -> Node2D:
	var instance := scene.instantiate()
	instance.global_position = position
	get_parent().add_child(instance)
	return instance

func handle_cutscene_start() -> void:
	var player: Player = PlayerConfig.get_player()
	if not player:
		print("Player not found")
		return
	
	player.disable_movement()
	player.animation_player.play("idle")
	TransitionLayer.animation_player.play("cutscene_start")
	fade_out_all_ui_elements()

func handle_cutscene_end(character_name = null, timeline = null) -> void:
	var player: Player = PlayerConfig.get_player()

	if not player:
		print("Player not found")
		return
	
	player.enable_movement()
	TransitionLayer.animation_player.play("cutscene_end")
	fade_in_all_ui_elements()

	if character_name:
		Dialog.set_timeline(character_name, timeline)

func fade_out_all_ui_elements() -> void:
	var ui_node: CanvasLayer = get_tree().get_first_node_in_group("ui")

	if not ui_node:
		print("UI node not found")
		return
	
	for child in ui_node.get_children():
		var ui_tween := child.create_tween()
		ui_tween.tween_property(child, "modulate:a", 0, 0.25)

func fade_in_all_ui_elements() -> void:
	var ui_node: CanvasLayer = get_tree().get_first_node_in_group("ui")

	if not ui_node:
		print("UI node not found")
		return
	
	for child in ui_node.get_children():
		var ui_tween := child.create_tween()
		ui_tween.tween_property(child, "modulate:a", 1, 0.25)
