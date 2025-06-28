extends Node3D


var direction: Vector3

var end_point

var tracer_scale = null


const SPEED = 3


func _ready():
	if not direction:
		queue_free()
	
	if tracer_scale:
		$MeshInstance3D.scale = tracer_scale
	
	
	await get_tree().create_timer(1).timeout
	queue_free()

func _physics_process(delta):
	global_position += direction * SPEED

	if end_point:
		if (self.global_position - end_point).length() < 2:
			queue_free()
