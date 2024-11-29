extends Node

# func save_game():
# 	var save_data = {}

# 	# Save current level/scene
# 	var current_scene = get_tree().current_scene
# 	var current_level = current_scene.scene_file_path
# 	save_data["current_level"] = current_level

# 	# Save PlayerConfig data
# 	save_data["player_config"] = PlayerConfig.get_player_config_save_data()

# 	# Save other persistent nodes
# 	var save_nodes = get_tree().get_nodes_in_group("Persist")
# 	var nodes_data = []
# 	for node in save_nodes:
# 		if node is Player:
# 			var player_data = node.save()
# 			save_data["player_data"] = player_data

# 		if node.scene_file_path.is_empty():
# 			print("Persistent node '%s' is not an instanced scene, skipped" % node.name)
# 			continue
# 		if not node.has_method("save"):
# 			print("Persistent node '%s' is missing a save() function, skipped" % node.name)
# 			continue
# 		var node_data = node.save()
# 		nodes_data.append(node_data)
# 	save_data["nodes"] = nodes_data

# 	# Write the save_data to file
# 	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
# 	print(JSON.stringify(save_data))
# 	save_file.store_string(JSON.stringify(save_data))
# 	save_file.close()

# func load_game():
# 	if not FileAccess.file_exists("user://savegame.save"):
# 		return # No save file to load

# 	# Read the save_data from the file
# 	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
# 	var json_string = save_file.get_as_text()
# 	save_file.close()

# 	var json = JSON.new()
# 	var parse_result = json.parse(json_string)
# 	if parse_result != OK:
# 		print("JSON Parse Error: ", json.get_error_message())
# 		return

# 	var save_data = json.data

# 	# Load the current level/scene
# 	var current_level = save_data.get("current_level", "")
# 	if current_level != "":
# 		# Load the scene
# 		get_tree().change_scene_to_file(current_level)
# 	else:
# 		print("No current_level found in save data")
# 		return

# 	# Wait for the new scene to load
# 	await get_tree().process_frame

# 	# Load checkpoint data
# 	var checkpoint_data = save_data.get("checkpoint_data", null)
# 	if checkpoint_data != null:
# 		PlayerConfig.current_checkpoint = checkpoint_data
# 	else:
# 		print("No checkpoint_data found in save data")

# 	# Load the player's data
# 	var player_data = save_data.get("player_data", null)
# 	if player_data != null:
# 		var player_node = get_tree().get_first_node_in_group("Player")
# 		if player_node != null:
# 			# Load PlayerConfig data
# 			PlayerConfig.set_player_config_data(player_data.get("config_data", {}))
# 			# Load the player data
# 			player_node.load(player_data)
# 		else:
# 			print("Player node not found in the scene")
# 	else:
# 		print("No player_data found in save data")

# 	# Load other persistent nodes
# 	var nodes_data = save_data.get("nodes", [])
# 	for node_data in nodes_data:
# 		if node_data['name'] == "Player": continue
# 		# Instantiate and add node to scene
# 		var new_object = load(node_data["filename"]).instantiate()
# 		get_node(node_data["parent"]).add_child(new_object)
# 		# Set the node's properties
# 		for key in node_data.keys():
# 			if key in ["filename", "parent"]:
# 				continue
# 			new_object.set(key, node_data[key])

# func _unhandled_input(_event: InputEvent) -> void:
# 	if Input.is_action_just_pressed("save_game"):
# 		print("Saving game")
# 		save_game()
	
# 	if Input.is_action_just_pressed("load_game"):
# 		print("Loading game")
# 		load_game()
