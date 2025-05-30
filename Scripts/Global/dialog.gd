extends Node

# TODO: way to handle save files creating dialog data BEFORE new characters added to dialog_data
var dialog_data := [
	{
		"character_name": "kiosk_guy",
		"timelines": [
			"kiosk_guy_1",
			"kiosk_guy_2",
		],
		"current_timeline": "kiosk_guy_1",
	},
	{
		"character_name": "fris_throw_dude",
		"timelines": [
			"fris_guy_1",
			# "fris_guy_2",
		],
		"current_timeline": "fris_guy_1",
	}
]

func get_dialog_data(character_name: String) -> Dictionary:
	for data in dialog_data:
		if data["character_name"] == character_name:
			return data
	return {}

func get_current_timeline(character_name: String) -> Variant:
	for data in dialog_data:
		if data["character_name"] == character_name:
			return data["current_timeline"]
	return null

func set_next_timeline(character_name: String) -> String:
	for data in dialog_data:
		if data["character_name"] == character_name:
			var index = data["timelines"].find(data["current_timeline"])
			if index < data["timelines"].size() - 1:
				var next_timeline = data["timelines"][index + 1]
				data["current_timeline"] = next_timeline
				return next_timeline
			else:
				print("Can't set next timeline for ", character_name, ". No more timelines.")
				return ""
	return ""

func set_timeline(character_name: String, timeline: Variant) -> void:
	for data in dialog_data:
		if data["character_name"] == character_name:
			data["current_timeline"] = timeline
			return
