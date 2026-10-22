extends SceneTree

var failures: Array[String] = []

func _initialize():
	call_deferred("run_tests")

func check(condition: bool, message: String):
	if not condition:
		failures.append(message)
		push_error(message)

func press_button(selection, device: int, button: int):
	var event = InputEventJoypadButton.new()
	event.device = device
	event.button_index = button
	event.pressed = true
	selection._input(event)

func run_tests():
	var metadata = root.get_node("MetaData")
	change_scene_to_file("res://Views/main_menu.tscn")
	await scene_changed
	var menu = current_scene
	menu._on_option_button_item_selected(1)
	check(root.msaa_3d == Viewport.MSAA_DISABLED and root.screen_space_aa == Viewport.SCREEN_SPACE_AA_FXAA, "FXAA selection must enable FXAA")
	menu._on_option_button_item_selected(2)
	menu._on_start_button_pressed()
	await scene_changed
	var selection = current_scene
	press_button(selection, 2, JOY_BUTTON_A)
	press_button(selection, 0, JOY_BUTTON_A)
	check(selection.id_list == [2, 0], "Out-of-order controller joins must keep device IDs")
	check(metadata.character_skins.has(3) and metadata.character_skins.has(1), "Skins must be assigned before the first frame")
	selection.players[2].set_ready()
	selection.players[2].next_character(3)
	check(not selection.players[2].ready_up, "Changing a character must clear ready state")
	selection.start_game()
	await scene_changed
	await physics_frame
	await physics_frame
	var game = current_scene
	var spawner = game.get_node("EnemySpawner")
	var players = get_nodes_in_group("player")
	var ids = players.map(func(p): return p.player_id)
	check(ids.has(1) and ids.has(3) and players.size() == 2, "Non-contiguous device IDs must spawn the correct players")
	check(players[0].global_position.distance_to(players[1].global_position) > 1.0, "Players must not spawn inside each other")
	check(not spawner.running and spawner.get_node("EnemySpawnerTimer").is_stopped(), "Enemies must wait for wave start")
	check(get_nodes_in_group("enemy").is_empty(), "Daytime must not spawn enemies")
	for player in players:
		player.collision_layer = 0
		player.hp = 1000000
	var weapon = load("res://Entities/Weapons/Hand/Revolver.tscn").instantiate()
	players[0].add_right_hand_weapon(weapon)
	await physics_frame
	var ammo = players[0].bullets
	weapon.action()
	check(players[0].bullets == ammo - 1, "Shooting must consume one round")
	players[0].drop_r_weapon()
	await physics_frame
	check(players[0].get_node("Visual/Pivot/HandItem").get_child_count() == 0, "Dropping a weapon must clear the hand")

	# Actual streetlight cone, visibility, range and wall occlusion.
	var point = load("res://Entities/Utility/spawnpoint.tscn").instantiate()
	point.position = Vector3(500, 0, 500)
	game.add_child(point)
	var light = SpotLight3D.new()
	light.position = Vector3(500, 10, 500)
	light.rotation_degrees.x = -90
	light.spot_range = 20
	light.spot_angle = 45
	light.add_to_group("spawn_blocking_light")
	game.add_child(light)
	check(not point.can_spawn(), "Enabled streetlight must protect a point inside its cone")
	light.hide()
	check(point.can_spawn(), "Disabled streetlight must allow spawning")
	light.show()
	var wall = StaticBody3D.new()
	wall.position = Vector3(500, 5, 500)
	var collision = CollisionShape3D.new()
	collision.shape = BoxShape3D.new()
	wall.add_child(collision)
	game.add_child(wall)
	await physics_frame
	await physics_frame
	check(point.can_spawn(), "A wall must block streetlight protection")
	point.queue_free()
	light.queue_free()
	wall.queue_free()

	metadata.wave_number = 100
	spawner.update_enemies()
	check(spawner.zombie_dogs == metadata.zombie_dog_waves.back(), "Late waves must handle exhausted wave tables")
	metadata.wave_number = 1
	game.start_wave()
	check(spawner.running, "Wave start must activate the spawner")
	var real_points = spawner.points.duplicate()
	spawner.points.clear()
	spawner.zombies = 1
	spawner.heavytaurs = 0
	spawner.zombie_dogs = 0
	check(not spawner.spawn_enemy(0) and spawner.zombies == 1, "Missing points must preserve pending enemies")
	var fake = load("res://tests/fake_spawnpoint.gd").new()
	fake.position = Vector3(80, 2, 80)
	game.add_child(fake)
	spawner.points.assign([fake])
	fake.allowed = false
	spawner.spawn_delays = [0.0, 0.0, 0.0]
	spawner._physics_process(0.016)
	check(spawner.zombies == 1 and get_nodes_in_group("enemy").is_empty(), "Blocked points must retry without consuming a spawn")
	fake.allowed = true
	spawner.spawn_delays = [0.0, 0.0, 0.0]
	spawner._physics_process(0.016)
	check(spawner.zombies == 0 and get_nodes_in_group("enemy").size() == 1, "Last enemy must spawn without dividing by zero")
	check(is_finite(spawner.spawn_delays[0]), "Spawn delay must remain finite after the last enemy")
	spawner.max_active_enemies = 1
	spawner.zombies = 1
	spawner.spawn_delays = [0.0, 0.0, 0.0]
	spawner._physics_process(0.016)
	check(spawner.zombies == 1, "Active enemy limit must preserve the pending wave")
	var delay = spawner.spawn_delays[0]
	paused = true
	for i in range(5):
		await physics_frame
	check(spawner.spawn_delays[0] == delay, "Pause must freeze spawn scheduling")
	game.hud._on_continue_button_pressed()
	check(not paused and not game.hud.get_node("PauseMenu").visible, "Continue must close the pause menu")

	# A second hit in the same frame must not duplicate awards or corpses.
	var enemy = get_nodes_in_group("enemy")[0]
	var money = players[0].money
	enemy.set_killer(players[0])
	enemy.get_hit(100)
	enemy.get_hit(100)
	await physics_frame
	await physics_frame
	check(players[0].money == money + 10, "A zombie must award money only once")
	check(metadata.ragdolls.size() == 1, "A zombie must create exactly one ragdoll")
	check(not is_instance_valid(enemy), "Dead zombie AI must be freed")
	spawner.stop_wave()

	# All enemy types must participate in cleanup and share the corpse budget.
	metadata.max_ragdolls = 2
	for kind in [0, 2, 2]:
		match kind:
			0: spawner.zombies = 1
			2: spawner.zombie_dogs = 1
		spawner.spawn_enemy(kind)
	for other in get_nodes_in_group("enemy"):
		other.get_hit(100)
		other.get_hit(100)
	await physics_frame
	await physics_frame
	await physics_frame
	check(metadata.ragdolls.size() <= 2, "Zombies and dogs must share the global corpse limit")
	for kind in range(3):
		match kind:
			0: spawner.zombies = 1
			1: spawner.heavytaurs = 1
			2: spawner.zombie_dogs = 1
		spawner.spawn_enemy(kind)
	game.end_wave()
	await physics_frame
	await physics_frame
	check(get_nodes_in_group("enemy").is_empty(), "Wave end must remove zombies, dogs and heavytaurs")
	check(not spawner.running, "Wave end must stop scheduling")
	for i in range(735):
		await physics_frame
	check(metadata.ragdolls.is_empty(), "Corpses must expire even when the global budget is not exceeded")
	for i in range(120):
		var decal = load("res://Entities/Effects/bullet_decal.tscn").instantiate()
		game.add_child(decal)
	await process_frame
	check(metadata.decals.size() == metadata.MAX_DECALS, "Sustained fire must not accumulate unlimited decals")

	# A fast rocket must hit thin geometry and explode only once.
	var barrier = StaticBody3D.new()
	barrier.position = Vector3(80, 3, 80)
	var barrier_shape = CollisionShape3D.new()
	barrier_shape.shape = BoxShape3D.new()
	barrier_shape.shape.size = Vector3(2, 2, 0.1)
	barrier.add_child(barrier_shape)
	game.add_child(barrier)
	await physics_frame
	await physics_frame
	var rocket = load("res://Entities/Effects/rocket.tscn").instantiate()
	rocket.position = Vector3(80, 3, 81)
	rocket.direction = Vector3.FORWARD
	game.add_child(rocket)
	rocket._physics_process(1.0)
	rocket.explode()
	check(rocket.exploded and rocket.position.z > 80.0, "Rocket sweep must detect thin barriers")
	await physics_frame
	await physics_frame
	var explosions = game.get_children().filter(func(n): return n.scene_file_path == "res://Entities/Effects/explosion.tscn")
	check(explosions.size() == 1, "Multiple collisions must not duplicate a rocket explosion")
	barrier.queue_free()
	spawner.points = real_points
	fake.queue_free()

	var streetlight = get_nodes_in_group("spawn_blocking_light")[0].get_parent().get_node("StaticBody3D")
	var caller = players[0].get_node("InteractionHandler")
	money = players[0].money
	streetlight.action(caller)
	streetlight.action(caller)
	check(players[0].money == money - 50, "A streetlight must charge only once")
	players[0].hp = 100
	players[0].get_hit(100)
	players[0].get_hit(100)
	await physics_frame
	check(players[0].dead and not game.game_over, "One player's death must allow teammates to continue")
	players[0].get_up()
	check(players[0].is_in_group("player") and players[0].hp == 10, "Revival must restore the player")
	players[0].get_hit(100)
	players[1].hp = 100
	players[1].get_hit(100)
	check(game.game_over and paused, "Last player death must stop the game")
	game.hud._on_back_to_menu_button_pressed()
	await scene_changed
	check(not paused and metadata.wave_number == 1 and metadata.players.is_empty() and metadata.character_skins.is_empty(), "New runs must clear old game state")
	check(not metadata.weapons.has("turret_crate"), "Removed turret must not remain available")
	current_scene.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	print("REGRESSION: ", "PASS" if failures.is_empty() else failures)
	var audio = root.get_node("Audio")
	audio.set_process(false)
	audio.stop_all()
	# Let the audio mixing thread release stopped playbacks before shutdown.
	OS.delay_msec(100)
	await process_frame
	quit(0 if failures.is_empty() else 1)
