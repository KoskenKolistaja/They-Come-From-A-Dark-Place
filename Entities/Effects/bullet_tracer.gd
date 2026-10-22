extends Node3D


var direction: Vector3

var end_point

var tracer_scale = null


const SPEED = 180.0


func _ready():
	if not direction:
		queue_free()
		return
	
	if tracer_scale:
		$MeshInstance3D.scale = tracer_scale
	
	
	var lifetime = Timer.new()
	lifetime.one_shot = true
	lifetime.timeout.connect(queue_free)
	add_child(lifetime)
	lifetime.start(1.0)

func _physics_process(delta):
	var step = direction * SPEED * delta
	if end_point != null and global_position.distance_squared_to(end_point) <= step.length_squared():
		queue_free()
		return
	global_position += step

	if end_point != null:
		if (self.global_position - end_point).length() < 2:
			queue_free()
