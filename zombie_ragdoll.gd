extends Node3D
var impact_data: Dictionary = {}

func copy_pose_from(source: Skeleton3D, bone_map: Dictionary):
	var skeleton: Skeleton3D = $metarig/Skeleton3D
	var to_local_pose = skeleton.global_transform.affine_inverse()
	# Retarget relative to each rig's rest pose: their bone axes and scale differ.
	for target_name in bone_map:
		var target_index = skeleton.find_bone(target_name)
		var source_index = source.find_bone(bone_map[target_name])
		if target_index < 0 or source_index < 0:
			continue
		var source_rest = source.global_transform * source.get_bone_global_rest(source_index)
		var source_pose = source.global_transform * source.get_bone_global_pose(source_index)
		var target_rest = skeleton.global_transform * skeleton.get_bone_global_rest(target_index)
		var target_pose = to_local_pose * source_pose * source_rest.affine_inverse() * target_rest
		skeleton.set_bone_global_pose(target_index, target_pose)
	skeleton.force_update_all_bone_transforms()

func activate(impact: Dictionary, color: Color):
	impact_data = impact
	var mesh = $"metarig/Skeleton3D/Character rough_004"
	var material = mesh.get_surface_override_material(0)
	if material == null:
		material = mesh.mesh.surface_get_material(0)
	material = material.duplicate()
	material.albedo_color = color
	mesh.set_surface_override_material(0, material)
	MetaData.add_ragdoll(self)
	$metarig/Skeleton3D.physical_bones_start_simulation()
	$metarig/Skeleton3D.force_update_all_bone_transforms()
	show()
	get_tree().physics_frame.connect(_apply_impact, CONNECT_ONE_SHOT)
	# Ragdolls share a global budget and have a short lifetime even below it.
	var lifetime = Timer.new()
	lifetime.one_shot = true
	lifetime.timeout.connect(queue_free)
	add_child(lifetime)
	lifetime.start(12.0)

func _apply_impact():
	if is_queued_for_deletion():
		return
	var point: Vector3 = impact_data.get("collision_point", global_position + Vector3.UP)
	var impulse: Vector3 = impact_data.get("direction", Vector3.ZERO) * impact_data.get("strength", 0.0)
	for bone in $metarig/Skeleton3D.get_children():
		if bone is PhysicalBone3D and bone.global_position.distance_squared_to(point) < 2.25:
			bone.apply_impulse(impulse, point - bone.global_position)

func _exit_tree():
	MetaData.delete_ragdoll(self)
