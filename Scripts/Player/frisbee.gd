class_name Frisbee
extends CharacterBody2D

enum STATES {
	Moving,
	Holding,
	Returning,
}

@export var speed := 300
@export var return_speed := 400
@export var bounce_velocity := -400
@export var boosted_velocity := -600
@export var bounce_to_return_time := 0.25

var direction := Vector2.RIGHT
var is_active := false: set = _set_is_active
var state := STATES.Moving
var is_throw_button_held := false
var can_bounce := false
var is_boosted := false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var bounce_area: Area2D = %BounceArea
@onready var sprite: Sprite2D = $Sprite2D
@onready var move_timer: Timer = $Timers/MoveTimer
@onready var hold_timer: Timer = $Timers/HoldTimer
@onready var player: Player = PlayerConfig.get_player()

func _ready() -> void:
	move_timer.timeout.connect(_on_move_timer_timeout)
	hold_timer.timeout.connect(_on_hold_timer_timeout)
	bounce_area.body_entered.connect(_on_bounce_area_body_entered)
	bounce_area.area_entered.connect(_on_bounce_area_area_entered)
	move_timer.start()

func activate_frisbee() -> void:
	state = STATES.Moving
	move_timer.start()

func deactivate_frisbee() -> void:
	velocity = Vector2.ZERO
	var shrink_tween = create_tween()
	shrink_tween.tween_property(sprite, "scale", Vector2.ZERO, 0.05)
	shrink_tween.finished.connect(queue_free_safely)

func queue_free_safely() -> void:
	# Ensure the player's reference is cleared before freeing the frisbee
	if player and player.current_frisbee == self:
		player.call_deferred("clear_frisbee_reference")
	queue_free()

func _physics_process(_delta: float) -> void:
	match state:
		STATES.Moving:
			velocity = direction * speed
			move_and_slide()
		STATES.Holding:
			can_bounce = true
			velocity = Vector2.ZERO
			# Transition to Returning if the button is not held
			if not is_throw_button_held:
				state = STATES.Returning
		STATES.Returning:
			can_bounce = false
			is_boosted = false
			collision_shape.disabled = true
			if player:
				var direction_to_player = (player.global_position - global_position).normalized()
				var distance_to_player = global_position.distance_to(player.global_position)
				if distance_to_player < 10:
					queue_free_safely()
				velocity = direction_to_player * return_speed
				move_and_slide()

func _on_move_timer_timeout() -> void:
	if state == STATES.Moving:
		if is_throw_button_held:
			state = STATES.Holding
			velocity = Vector2.ZERO
			hold_timer.start()
		else:
			state = STATES.Returning

func _on_hold_timer_timeout() -> void:
	if state == STATES.Holding:
		state = STATES.Returning

func _on_bounce_area_body_entered(body: Player) -> void:
	if body and state == STATES.Returning:
		body.current_frisbee = null
		deactivate_frisbee()
	elif body and state == STATES.Holding and can_bounce:
		body.bounce(bounce_velocity if not is_boosted else boosted_velocity)
		await get_tree().create_timer(bounce_to_return_time).timeout
		state = STATES.Returning

func _on_bounce_area_body_exited(body: Player) -> void:
	if body and state == STATES.Returning:
		body.current_frisbee = null
		deactivate_frisbee()

func _on_bounce_area_area_entered(area: Area2D) -> void:
	if area and state == STATES.Moving or state == STATES.Holding:
		is_boosted = true

func _set_is_active(value: bool) -> void:
	is_active = value
	if is_active:
		activate_frisbee()
	else:
		deactivate_frisbee()
