extends GPUParticles3D


# Called when the node enters the scene tree for the first time.
func _ready():
	emitting = true
	$Fire.emitting = true
	$Flash.emitting = true
	$Smoke.emitting = true
	$AnimationPlayer.play("explode")
