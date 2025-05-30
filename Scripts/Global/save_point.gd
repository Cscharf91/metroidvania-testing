class_name SavePoint
extends Area2D

@onready var start_time := Time.get_ticks_msec()

func _ready() -> void:
	body_entered.connect(on_body_entered)

func on_body_entered(player: Player) -> void:
	if player == null:
		return
	
	if Time.get_ticks_msec() - start_time < 1000:
		return # Small hack to prevent saving at the game start.
	# Make Game save the data.
	Game.get_singleton().save_game()
	# Starting coords for the delta vector feature.
	Game.get_singleton().reset_map_starting_coords()
	print("Game saved.")

func _draw() -> void:
	pass
	# Draws the circle.
	#$CollisionShape2D.shape.draw(get_canvas_item(), Color.BLUE)
