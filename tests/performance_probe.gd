extends SceneTree

# Run with --headless --fixed-fps 60 --script res://tests/performance_probe.gd
# CPU/physics comparison only: this does not measure GPU rendering cost.
func _initialize():
	call_deferred("run_probe")

func run_probe():
	seed(42)
	var rendered = DisplayServer.get_name() != "headless"
	if rendered:
		root.mode = Window.MODE_WINDOWED
		root.size = Vector2i(960, 540)
		RenderingServer.viewport_set_measure_render_time(root.get_viewport_rid(), true)
	var metadata = root.get_node("MetaData")
	metadata.players = [0]
	metadata.character_skins = {1: "suitman"}
	var menu = load("res://Views/main_menu.tscn").instantiate()
	root.add_child(menu)
	menu.generate_input_map()
	if rendered:
		menu._on_settings_button_pressed()
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/probe-settings.png")
	menu.queue_free()
	var scene = load("res://Views/GameScene.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	if "--lights-on" in OS.get_cmdline_user_args():
		for light in scene.find_children("*", "SpotLight3D", true, false):
			light.show()
		print("PROBE mode: all streetlights enabled")
	await physics_frame
	await physics_frame
	# Keep the benchmark running even when enemies reach their target.
	for player in get_nodes_in_group("player"):
		player.collision_layer = 0
		player.hp = 1000000
	var spawner = scene.get_node("EnemySpawner")
	spawner.set_physics_process(false)
	spawner.get_node("EnemySpawnerTimer").stop()
	var packed = load("res://Entities/zombie.tscn")
	var start = Time.get_ticks_usec()
	for i in range(60):
		var enemy = packed.instantiate()
		enemy.position = Vector3((i % 10) * 2.0 - 10.0, 1, (i / 10) * 2.0 - 15.0)
		scene.add_child(enemy)
	var spawn_ms = (Time.get_ticks_usec() - start) / 1000.0
	for i in range(30):
		await physics_frame
	if rendered:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/probe-alive.png")
	var samples: Array[float] = []
	var gpu_samples: Array[float] = []
	for i in range(180):
		start = Time.get_ticks_usec()
		await physics_frame
		samples.append((Time.get_ticks_usec() - start) / 1000.0)
		if rendered:
			gpu_samples.append(RenderingServer.viewport_get_measured_render_time_gpu(root.get_viewport_rid()))
	samples.sort()
	print("PROBE alive: spawn_ms=", spawn_ms, " median_ms=", samples[90], " p95_ms=", samples[171], " nodes=", Performance.get_monitor(Performance.OBJECT_NODE_COUNT), " physics_objects=", Performance.get_monitor(Performance.PHYSICS_3D_ACTIVE_OBJECTS))
	if rendered:
		gpu_samples.sort()
		print("PROBE GPU: median_ms=", gpu_samples[90], " p95_ms=", gpu_samples[171])
	for enemy in get_nodes_in_group("enemy"):
		if enemy.has_method("get_hit"):
			enemy.get_hit(100)
	for i in range(5):
		await physics_frame
	print("PROBE dead: ragdolls=", metadata.ragdolls.size(), " nodes=", Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	if rendered:
		for i in range(60):
			await physics_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://.godot/probe-dead.png")
	for i in range(780):
		await physics_frame
	print("PROBE settled: nodes=", Performance.get_monitor(Performance.OBJECT_NODE_COUNT), " physics_objects=", Performance.get_monitor(Performance.PHYSICS_3D_ACTIVE_OBJECTS))
	current_scene.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	var audio = root.get_node("Audio")
	audio.set_process(false)
	if audio.has_method("stop_all"):
		audio.stop_all()
	else:
		for child in audio.find_children("*", "AudioStreamPlayer", true, false):
			child.stop()
			child.stream = null
	OS.delay_msec(100)
	await process_frame
	quit()
