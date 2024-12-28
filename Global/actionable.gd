class_name Actionable
extends Area2D

@export var dialog_timeline: DialogicTimeline
@export var character_name: String

enum Type { ACTION, DIALOGUE }
@export var type: Type = Type.DIALOGUE

func action() -> void:
	match type:
		Type.ACTION:
			# Do some shit
			pass
		Type.DIALOGUE:
			if dialog_timeline and Dialogic.current_timeline == null:
				var player: Player = get_tree().get_first_node_in_group("player")
				if not player:
					print("Player not found")
					return
				player.disable_movement()
				player.animation_player.play("idle")
				TransitionLayer.animation_player.play("cutscene_start")
				var ui_node: CanvasLayer = get_tree().get_first_node_in_group("ui")
				ui_node.visible = false
				await TransitionLayer.animation_player.animation_finished
				var layout = Dialogic.start(dialog_timeline)
				if character_name:
					layout.register_character(character_name, owner)
				else:
					print("No registered character for ", owner.name, "'s text bubble")
