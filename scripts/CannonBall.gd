extends RigidBody2D


func _process(_delta):
	if global_position.x < -100 || global_position.x > 1500:
		queue_free()
