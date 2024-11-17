class_name MoveState extends LimboState

@onready var player: Player = owner

func _setup() -> void:
  add_event_handler("movement_stopped", _on_movement_stopped)
  add_event_handler("in_air", _on_in_air)

func _enter() -> void:
  player.animation_player.play("run")

func _exit() -> void:
  pass

func _update(delta: float) -> void:
  if not player.is_on_floor() and not player.is_coyote_time:
    dispatch("in_air")
    return
  
  handle_movement(delta)
  
  if Input.is_action_just_pressed("jump"):
    player.jump()
    dispatch("in_air")
    

  var started_on_floor = player.is_on_floor()
  player.move_and_slide()
  var ended_on_floor = player.is_on_floor()

  if started_on_floor and not ended_on_floor:
    player.is_coyote_time = true

func handle_movement(_delta: float) -> void:
  if player.direction != 0:
    %Sprite2D.flip_h = player.direction > 0
  else:
    if player.velocity.x == 0:
      dispatch("movement_stopped") # Return to idle if fully stopped


func _on_movement_stopped(_cargo = null) -> bool:
  return false

func _on_in_air(_cargo = null):
  return false