class_name Actionable
extends Area2D

@export var dialog_timeline: String
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
				Utils.handle_cutscene_start()
				await TransitionLayer.animation_player.animation_finished
				var layout = Dialogic.start(dialog_timeline)
				if character_name:
					layout.register_character(character_name, owner)
				else:
					print("No registered character for ", owner.name, "'s text bubble")
