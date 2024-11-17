class_name MoveState extends LimboState

@onready var player: Player = owner

var previous_state := ""
var can_boost_jump := false: set = set_can_boost_jump
var boost_jump_timer := 0.5

func _setup() -> void:
  add_event_handler("movement_stopped", _on_movement_stopped)
  add_event_handler("in_air", _on_in_air)

func _enter() -> void:
  previous_state = %LimboHSM.get_previous_active_state().name
  if previous_state == "AirDashState":
    can_boost_jump = true
  player.animation_player.play("run")

func _exit() -> void:
  pass

func _update(delta: float) -> void:
  if not player.is_on_floor() and not player.is_coyote_time:
    dispatch("in_air")
    return
  
  handle_movement(delta)
  
  if Input.is_action_just_pressed("jump"):
    player.jump(can_boost_jump)
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

func set_can_boost_jump(new_val: bool) -> void:
  can_boost_jump = new_val
  
  if new_val == false:
    return
  
  print("Can boost jump")
  await get_tree().create_timer(boost_jump_timer).timeout
  can_boost_jump = false
  print("No mo' boost jump")