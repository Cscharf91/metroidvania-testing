class_name Actionable
extends Area2D

@export var character_name: String

enum Type {ACTION, DIALOGUE}
@export var type: Type = Type.DIALOGUE

func action() -> void:
	match type:
		Type.ACTION:
			# Do some shit
			pass
		Type.DIALOGUE:
			var current_timeline = Dialog.get_current_timeline(character_name)
			if not current_timeline:
				print("No current timeline attached to the character with this actionable")
				return
			
			if Dialogic.current_timeline == null:
				Utils.handle_cutscene_start()
				await TransitionLayer.animation_player.animation_finished
				var layout = Dialogic.start(current_timeline)

				var player = PlayerConfig.get_player()
				if player:
					layout.register_character("player", player)
				else:
					print("No registered character for player's text bubble")
				
				if character_name:
					layout.register_character(character_name, owner)
				else:
					print("No registered character for ", owner.name, "'s text bubble")
