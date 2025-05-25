class_name CollectAllController
extends Node

signal challenge_success
signal challenge_failure
signal challenge_reset

@export var collectible_items: Array[CollectibleItem]
@export var reward_item: RewardItem
@export var time_limit: float = 0.0

var collected_count: int = 0
var challenge_active: bool = false
var challenge_has_been_won: bool = false
var timer: Timer

# Unique ID for MetSys storage
@export var metsys_id_suffix: String = "default_collect_all_controller"
var unique_metsys_id: String

func _ready() -> void:
	unique_metsys_id = name + "_" + metsys_id_suffix
	self.set_meta(&"object_id", unique_metsys_id)

	# MetSys.register_storable_object will call _handle_challenge_already_won if this object_id
	# was previously stored, which will then set challenge_has_been_won to true.
	challenge_has_been_won = false
	MetSys.register_storable_object(self, _handle_challenge_already_won)

	if challenge_has_been_won:
		print(name + ": Challenge state loaded from MetSys - was already won. Performing cleanup.")
		_post_win_cleanup()
		if reward_item:
			reward_item.activate()
		return

	if not reward_item:
		printerr(name + ": Reward Item node not assigned!")

	if time_limit > 0:
		timer = Timer.new()
		timer.wait_time = time_limit
		timer.one_shot = true
		timer.timeout.connect(_on_timer_timeout)
		add_child(timer)

	Events.player_reset_for_challenge.connect(reset_challenge_on_player_death)

	if collectible_items.is_empty():
		printerr(name + ": No collectible items assigned to the controller.")

	for item in collectible_items:
		if not item is CollectibleItem:
			printerr(name + ": Item in collectible_items is not a CollectibleItem instance: ", item)
			continue
		if not is_instance_valid(item):
			printerr(name + ": Item in collectible_items is not valid: ", item)
			continue
		if not item.collected.is_connected(_on_item_interaction):
			item.collected.connect(_on_item_interaction)
		item.reset_collectible()

	if reward_item:
		reward_item.reset_reward()

func _handle_challenge_already_won() -> void:
	print(name + ": MetSys callback indicates challenge was previously won.")
	challenge_has_been_won = true
	challenge_active = false

func _post_win_cleanup() -> void:
	print(name + ": Post-win cleanup. Removing collectibles.")
	for item_node in collectible_items:
		if item_node is CollectibleItem:
			if is_instance_valid(item_node):
				item_node.queue_free()

func _on_item_interaction(item_instance: CollectibleItem) -> void:
	if challenge_has_been_won:
		return

	if not challenge_active:
		start_challenge(item_instance)
	else:
		collected_count += 1
		print(name + ": Item collected! Progress: ", collected_count, "/", collectible_items.size())
		if collected_count >= collectible_items.size():
			_succeed_challenge()

func start_challenge(triggering_item: CollectibleItem = null) -> void:
	if challenge_has_been_won:
		return

	if challenge_active and triggering_item != null:
		return
	if challenge_active and not triggering_item:
		return

	print(name + ": Starting collect-all challenge." + (" Triggered by: " + triggering_item.name if triggering_item else ""))
	challenge_active = true
	collected_count = 0
	challenge_has_been_won = false

	for item_node in collectible_items:
		if item_node != triggering_item:
			if item_node is CollectibleItem and is_instance_valid(item_node):
				item_node.reset_collectible()

	if triggering_item:
		if not is_instance_valid(triggering_item):
			printerr(name + ": start_challenge called with an invalid triggering_item.")
			challenge_active = false
			return
		
		collected_count = 1
		print(name + ": Item '" + triggering_item.name + "' initiated challenge. Progress: " + str(collected_count) + "/" + str(collectible_items.size()))
		
		if collected_count >= collectible_items.size():
			print(name + ": start_challenge - First item is the only item. Calling _succeed_challenge.")
			_succeed_challenge()
			return

	if timer and time_limit > 0:
		timer.start()

func _succeed_challenge() -> void:
	if challenge_has_been_won or not challenge_active:
		if challenge_has_been_won:
			# print(name + ": _succeed_challenge - Already won, aborting redundant success call.")
			pass
		return

	print(name + ": Collect-all challenge succeeded!")
	challenge_active = false
	challenge_has_been_won = true
	if timer:
		timer.stop()
	
	MetSys.store_object(self)
	challenge_success.emit()
	_post_win_cleanup()

	if reward_item:
		if is_instance_valid(reward_item):
			reward_item.activate()
		else:
			printerr(name + ": Reward item is invalid when trying to activate in _succeed_challenge.")
	else:
		printerr(name + ": Reward item node not assigned to controller.")

func _on_timer_timeout() -> void:
	if not challenge_active:
		return
	
	print(name + ": Collect-all challenge failed! Time ran out.")
	challenge_active = false
	challenge_failure.emit()
	_reset_internal_state(true)

func reset_challenge_on_player_death() -> void:
	print(name + ": Received player request to reset challenge.")
	_reset_internal_state(false)

func _reset_internal_state(due_to_failure: bool) -> void:
	var was_active = challenge_active
	challenge_active = false
	collected_count = 0
	
	if timer:
		timer.stop()
	
	if was_active and not due_to_failure and not challenge_has_been_won:
		print(name + ": Resetting collectibles for challenge." + (" Due to failure." if due_to_failure else ""))
		challenge_reset.emit()

	if not challenge_has_been_won:
		for item_node in collectible_items:
			if item_node is CollectibleItem:
				item_node.reset_collectible()
	
	if reward_item:
		if not challenge_has_been_won:
			reward_item.reset_reward()
