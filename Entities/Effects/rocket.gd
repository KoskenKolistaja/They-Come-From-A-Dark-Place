extends Area3D


@export var explosion: PackedScene

var direction = Vector3.FORWARD

const SPEED = 30.0

var player
var exploded = false


func _ready():
	look_at_from_position(self.global_position, self.global_position + direction)


func _physics_process(delta):
	if exploded:
		return
	var destination = global_position + direction.normalized() * SPEED * delta
	var ray = PhysicsRayQueryParameters3D.create(global_position, destination, collision_mask)
	if is_instance_valid(player):
		ray.exclude = [player.get_rid()]
	var hit = get_world_3d().direct_space_state.intersect_ray(ray)
	if not hit.is_empty():
		global_position = hit.position
		explode()
	else:
		global_position = destination


func explode():
	if exploded:
		return
	exploded = true
	set_physics_process(false)
	$CollisionShape3D.set_deferred("disabled", true)
	call_deferred("spawn_explosion")

func spawn_explosion():
	var explosion_instance = explosion.instantiate()
	explosion_instance.player = player
	explosion_instance.position = get_tree().current_scene.to_local(global_position)
	get_tree().current_scene.add_child(explosion_instance)
	$GPUParticles3D.emitting = false
	$GPUParticles3D2.emitting = false
	$Sparks.emitting = false
	$AudioStreamPlayer3D.stop()
	$rocket.hide()
	$OmniLight3D.hide()
	$Timer.start(1.0)



func _on_timer_timeout():
	queue_free()


func _on_body_entered(body):
	explode()
