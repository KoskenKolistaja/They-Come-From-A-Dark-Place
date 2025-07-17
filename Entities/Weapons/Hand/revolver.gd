extends Node3D



var loaded = true

var type = "revolver"


var player

var left = false

var impact_strength = 15


@export var tracer: PackedScene
@export var strike: PackedScene
@export var decal: PackedScene

func action():
	if loaded and player.bullets > 0:
		$AnimationPlayer.play("shoot")
		$AudioStreamPlayer.play()
		$Handle/GPUParticles3D.emitting = true
		loaded = false
		$Timer.start()
		check_for_hit()
		player.bullets -= 1
		player.update_hud_ammo()

func spawn_trace(collision_point):
	var ray_start = $Handle/GPUParticles3D.global_position
	var ray_end = to_global($Handle/Cube/RayCast3D.get_target_position())
	var direction = (ray_end - ray_start).normalized()
	var tracer_instance = tracer.instantiate()
	if collision_point:
		tracer_instance.end_point = collision_point
	tracer_instance.direction = direction
	tracer_instance.global_transform = $Handle/GPUParticles3D.global_transform
	tracer_instance.tracer_scale = Vector3(3,3,1)
	tracer_instance.look_at_from_position($Handle/Cube/RayCast3D.global_position,$Handle/Cube/RayCast3D.global_position + direction)
	get_tree().current_scene.add_child(tracer_instance)

func spawn_strike(spawn_position):
	var strike_instance = strike.instantiate()
	get_tree().current_scene.add_child(strike_instance)
	strike_instance.global_position = spawn_position

func spawn_decal(spawn_position, parent, normal):
	var decal_instance: Node3D = decal.instantiate()
	parent.add_child(decal_instance)
	var child_transform = decal_instance.global_transform
	decal_instance.global_transform = child_transform
	decal_instance.global_position = spawn_position
	print(decal_instance)
	print(decal_instance.scale)
	print(decal_instance.global_position)
	
	decal_instance.look_at_from_position(decal_instance.global_position,(decal_instance.global_position + normal*50))


func check_for_hit():
	var ray: RayCast3D = $Handle/Cube/RayCast3D
	var collider = ray.get_collider()
	var collision_point = ray.get_collision_point()
	var normal = ray.get_collision_normal()
	
	
	spawn_trace(collision_point)
	if not collider:
		return
	else:
		spawn_decal(collision_point, collider,normal)
		spawn_strike($Handle/Cube/RayCast3D.get_collision_point())
		if collider.has_method("get_hit"):
			
			
			
			if collider.has_method("store_impact"):
				var dic = {}
				
				var start_point = ray.global_position
				var end_point = $Handle/Cube/EndPoint.global_position
				var direction = (end_point - start_point).normalized()
				
				dic = {"collision_point": collision_point, "direction": direction, "strength" : impact_strength, "killer": player}
				
				
				collider.store_impact(dic)
				
			
			collider.get_hit()


func _on_timer_timeout():
	loaded = true
