extends Node3D


var direction: Vector3

var end_point

const SPEED = 3


func _ready():
	if not direction:
		queue_free()
	
	
	await get_tree().create_timer(0.5).timeout
	queue_free()

func _physics_process(delta):
	global_position += direction * SPEED

	if end_point:
		if (self.global_position - end_point).length() < 2:
			queue_free()
