extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: PhantomCamera2D = $PhantomCamera2D

var player_can_throw := false

const CutsceneFrisbee := preload("res://Objects/Cutscenes/cutscene_frisbee.tscn")

func _ready() -> void:
	animated_sprite.play("idle")

	body_entered.connect(_on_body_entered)
	Dialogic.signal_event.connect(_on_dialogic_event)

func _physics_process(_delta: float) -> void:
	if player_can_throw:
		var player = PlayerConfig.get_player()
		if player:
			player.handle_frisbee()
		if Input.is_action_just_pressed("throw_frisbee"):
			await get_tree().create_timer(0.8).timeout
			Dialogic.start("fris_guy_2")
			player_can_throw = false

func _on_body_entered(player_body: Player) -> void:
	if not player_body:
		return
	
	Utils.handle_cutscene_start()
	camera.priority = 2
	var current_timeline = Dialog.get_current_timeline("fris_throw_dude")
	var layout = Dialogic.start(current_timeline)

	layout.register_character("player", player_body)
	layout.register_character("fris_throw_dude", self)

func _on_throw_frisbee() -> void:
	Utils.spawn(CutsceneFrisbee, global_position + Vector2(0, 5))

func _on_dialogic_event(event_name: String) -> void:
	if event_name == "throw_frisbee":
		_on_throw_frisbee()
	if event_name == "player_can_throw":
		player_can_throw = true
