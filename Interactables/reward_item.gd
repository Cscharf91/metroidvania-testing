class_name RewardItem
extends Area2D

signal reward_activated

@export var activation_animation_name: StringName = &"activate"
@export var idle_animation_name: StringName = &"idle"

@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null

var is_active: bool = false

func _ready() -> void:
	set_reward_active(false, true)

func set_reward_active(active: bool, silent_set: bool = false) -> void:
	if is_active == active and not silent_set:
		return

	is_active = active

	if active:
		visible = true
		# Enable collision, interaction, etc.
		# For example, if it's an Area2D:
		# if get_node_or_null("CollisionShape2D"):
		#    get_node_or_null("CollisionShape2D").disabled = false
		
		if animation_player and animation_player.has_animation(activation_animation_name) and not silent_set:
			animation_player.play(activation_animation_name)
		elif animation_player and animation_player.has_animation(&"default") and not silent_set: # Fallback
			animation_player.play(&"default")
		
		reward_activated.emit()
		print(name + ": Reward activated!")
	else:
		visible = false
		# Disable collision, interaction, etc.
		# if get_node_or_null("CollisionShape2D"):
		#    get_node_or_null("CollisionShape2D").disabled = true
		
		if animation_player and animation_player.has_animation(idle_animation_name) and not silent_set:
			animation_player.play(idle_animation_name)
		elif animation_player and animation_player.has_animation(&"default") and not silent_set: # Fallback for initial state
			animation_player.stop() # Or play an "inactive" animation
		print(name + ": Reward deactivated/hidden.")


func activate() -> void:
	set_reward_active(true)

func reset_reward() -> void:
	# This function is called by the CollectAllController when the challenge resets
	set_reward_active(false)
