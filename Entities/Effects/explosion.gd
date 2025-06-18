extends GPUParticles3D



func _ready():
	emitting = true
	$Flash.emitting = true
	$Fire.emitting = true
	$Smoke.emitting = true
	$AnimationPlayer.play("explode")
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var bodies = $Area3D.get_overlapping_bodies()
	for b in bodies:
		if b.has_method("get_hit"):
			b.get_hit(10)
		elif b.has_method("apply_impulse"):
			var vector = b.global_position - self.global_position
			var effect = get_explosion_effect(vector.length(),10)
			b.apply_impulse(vector.normalized()*effect*20,self.global_position)
	
	
	get_tree().current_scene.shake_camera()

func get_explosion_effect(distance: float, max_radius: float) -> float:
	if distance >= max_radius:
		return 0.0
	var normalized = clamp(1.0 - (distance / max_radius), 0.0, 1.0)
	return pow(normalized, 2) # Squared for sharper falloff (more "crisp")



func _on_timer_timeout():
	queue_free()
