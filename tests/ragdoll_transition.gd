extends SceneTree

var expected_poses: Dictionary = {}
var failures: Array[String] = []
var visible_corpses = 0

func _initialize():
	call_deferred("run_test")

func inspect_added_node(node: Node):
	if node.scene_file_path == "res://Entities/zombie_corpse.tscn":
		node.visibility_changed.connect(inspect_first_pose.bind(node))

func inspect_first_pose(corpse: Node3D):
	if not corpse.visible:
		return
	visible_corpses += 1
	var skeleton: Skeleton3D = corpse.get_node("metarig/Skeleton3D")
	for bone_name in expected_poses:
		var actual = skeleton.get_bone_global_pose(skeleton.find_bone(bone_name))
		if not actual.is_equal_approx(expected_poses[bone_name]):
			failures.append("First visible pose differs at " + bone_name)

func run_test():
	var scene = Node3D.new()
	root.add_child(scene)
	current_scene = scene
	var rendered = DisplayServer.get_name() != "headless"
	if rendered:
		root.mode = Window.MODE_WINDOWED
		root.size = Vector2i(960, 540)
		var camera = Camera3D.new()
		scene.add_child(camera)
		camera.position = Vector3(0, 1.1, 3.5)
		camera.current = true
		var light = DirectionalLight3D.new()
		light.rotation_degrees = Vector3(-35, -25, 0)
		scene.add_child(light)
	node_added.connect(inspect_added_node)
	for phase in [0.1, 0.4, 0.7]:
		var zombie = load("res://Entities/zombie.tscn").instantiate()
		scene.add_child(zombie)
		var animation: AnimationTree = zombie.get_node("zombie/AnimationTree")
		zombie.state_machine.start("running")
		animation.advance(phase)
		animation.active = false
		var source: Skeleton3D = zombie.get_node("zombie/Armature/Skeleton3D")
		source.force_update_all_bone_transforms()
		var reference = zombie.corpse.instantiate()
		reference.transform = zombie.transform
		scene.add_child(reference)
		var target: Skeleton3D = reference.get_node("metarig/Skeleton3D")
		expected_poses.clear()
		for target_name in zombie.bone_name_map:
			var source_index = source.find_bone(zombie.bone_name_map[target_name])
			var target_index = target.find_bone(target_name)
			var rest = source.global_transform * source.get_bone_global_rest(source_index)
			var pose = source.global_transform * source.get_bone_global_pose(source_index)
			expected_poses[target_name] = target.global_transform.affine_inverse() * pose * rest.affine_inverse() * target.global_transform * target.get_bone_global_rest(target_index)
		reference.free()
		if rendered:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://.godot/transition-before-%s.png" % phase)
		zombie.get_hit(100)
		await process_frame
		if rendered:
			for frame in range(3):
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png("res://.godot/transition-after-%s-%d.png" % [phase, frame])
		for corpse in root.get_node("MetaData").ragdolls.duplicate():
			corpse.queue_free()
		await process_frame
	if visible_corpses != 3:
		failures.append("Expected three visible corpse transitions")
	print("RAGDOLL TRANSITION: ", "PASS (21 bones, 3 animation phases)" if failures.is_empty() else failures)
	node_added.disconnect(inspect_added_node)
	scene.queue_free()
	current_scene = null
	await process_frame
	var audio = root.get_node("Audio")
	audio.set_process(false)
	audio.stop_all()
	OS.delay_msec(100)
	await process_frame
	quit(0 if failures.is_empty() else 1)
