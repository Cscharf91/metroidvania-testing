class_name Actionable
extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start := "start"

enum Type {ACTION, DIALOGUE}
@export var type: Type = Type.DIALOGUE

func action() -> void:
	match type:
		Type.ACTION:
			# Do some shit
			pass
		Type.DIALOGUE:
			if dialogue_resource:
				DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)