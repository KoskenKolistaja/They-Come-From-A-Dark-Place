extends GPUParticles3D


# Called when the node enters the scene tree for the first time.
func _ready():
	emitting = true
	
	var lifetime = Timer.new()
	lifetime.one_shot = true
	lifetime.timeout.connect(queue_free)
	add_child(lifetime)
	lifetime.start(1.0)
