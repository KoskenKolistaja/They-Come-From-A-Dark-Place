extends Area3D


@export var explosion: PackedScene

var direction = Vector3.FORWARD

const SPEED = 0.5

func _ready():
	look_at_from_position(self.global_position, self.global_position + direction)

func _physics_process(delta):
	
	global_position += direction.normalized() * SPEED


func explode():
	var explosion_instance = explosion.instantiate()
	get_tree().current_scene.add_child(explosion_instance)
	explosion_instance.global_position = self.global_position
	$GPUParticles3D.emitting = false
	$GPUParticles3D2.emitting = false
	$Sparks.emitting = false
	$rocket.hide()
	$OmniLight3D.hide()
	$CollisionShape3D.disabled = true
	await get_tree().create_timer(1).timeout
	queue_free()



func _on_timer_timeout():
	queue_free()


func _on_body_entered(body):
	explode()
