class_name StaticCameraOverride
extends Area2D

@onready var camera: PhantomCamera2D = $PhantomCamera2D
var stored_transform: Transform2D
var player_in_area: Player = null
var player_camera_host: Node = null
var original_player_camera_priority: int = 0

func _ready() -> void:
	assert(camera != null, "PhantomCamera2D not found")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Set this camera to be completely static
	camera.follow_mode = PhantomCamera2D.FollowMode.NONE
	camera.inactive_update_mode = PhantomCamera2D.InactiveUpdateMode.NEVER

func _physics_process(_delta: float) -> void:
	if player_in_area:
		# Force the camera to maintain its exact transform
		camera.global_transform = stored_transform
		
		# Also ensure player's camera doesn't affect anything
		if player_camera_host:
			for child in player_camera_host.get_children():
				if child is Camera2D and child != camera:
					child.enabled = false

func _on_body_entered(body: Player) -> void:
	if body:
		player_in_area = body
		
		# Store the current camera transform
		stored_transform = camera.global_transform
		
		# Capture player's camera host if it exists
		if body.has_node("PhantomCameraHost"):
			player_camera_host = body.get_node("PhantomCameraHost")
		
			var player_camera = body.camera
			if player_camera:
				original_player_camera_priority = player_camera.priority
				player_camera.priority = 0
				player_camera.follow_mode = PhantomCamera2D.FollowMode.NONE
		
		# Set our camera to highest priority
		camera.priority = 9999

func _on_body_exited(body: Player) -> void:
	if body:
		player_in_area = null
		player_camera_host = null
		
		# Re-enable player's camera
		var player_camera = body.camera
		if player_camera:
			player_camera.priority = original_player_camera_priority
			player_camera.follow_mode = PhantomCamera2D.FollowMode.FRAMED
		
		# Reset our camera priority
		camera.priority = 0
