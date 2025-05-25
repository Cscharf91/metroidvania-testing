extends RigidBody2D


func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.bounce(PlayerConfig.bounce_velocity * 1.5)
