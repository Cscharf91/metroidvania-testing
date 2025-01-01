extends Area2D

var has_hidden_from_player := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("idle")
	body_entered.connect(_on_player_entered)
	Dialogic.signal_event.connect(_on_dialogic_event)

func _on_player_entered(body: Player) -> void:
	if body is not Player or has_hidden_from_player:
		return
	animation_player.play("alert")
	has_hidden_from_player = true

func _on_dialogic_event(event_name: String) -> void:
	if event_name == "kiosk_peek":
		_kiosk_peek()
	if event_name == "sword_falling":
		animation_player.stop()
	if event_name == "kiosk_resume_animation":
		animation_player.play("idle")
		var player = PlayerConfig.get_player()
		if player:
			player.animation_player.play("idle")

func _kiosk_peek() -> void:
	animation_player.play("peek")
	await animation_player.animation_finished
	animation_player.play("idle")
