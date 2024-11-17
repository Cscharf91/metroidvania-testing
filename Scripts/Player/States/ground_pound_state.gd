class_name GroundPoundState extends LimboState

@onready var player: Player = owner

func _enter() -> void:
    print("Entering Ground Pound State")

func _exit() -> void:
    print("Exiting Ground Pound State")

func _update(_delta: float) -> void:
    player.move_and_slide()

    if player.is_on_floor():
        dispatch("movement_stopped")
