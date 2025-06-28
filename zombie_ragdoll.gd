extends Node3D

var impact


#func _ready():
	#
	#if impact:
		##cast_impact_ray()
		#apply_impact()





func set_color(exported_color):
	var mesh: MeshInstance3D = $"metarig/Skeleton3D/Character rough_004"
	var mat: StandardMaterial3D = mesh.get_surface_override_material(0)
	mat.albedo_color = exported_color





#func cast_impact_ray():
	#
	#var ray = RayCast3D.new()
	#get_tree().current_scene.add_child(ray)
	#ray.set_collision_mask_value(1, false)
	#ray.set_collision_mask_value(2, true)
	#
	#ray.global_rotation_degrees = Vector3(0,0,0)
	#
	#ray.global_position = impact["start_point"]
	#ray.target_position = ray.to_local(impact["end_point"])
	#
	#
	#
	#await get_tree().physics_frame
	#await get_tree().physics_frame
	#
	#
	#
	#if ray.is_colliding():
		#var collider = ray.get_collider()
		#if collider:
			#if collider.has_method("apply_impulse"):
				#var vector = (impact["end_point"] - impact["start_point"]).normalized()
				#collider.apply_impulse( vector * impact["strength"]*3*20)
	#
	#await  get_tree().create_timer(0.1).timeout
	#ray.queue_free()
