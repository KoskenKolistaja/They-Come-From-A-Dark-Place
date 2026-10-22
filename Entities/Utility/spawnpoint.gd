extends Node3D

@export var minimum_player_distance: float = 5.0
@export var minimum_enemy_distance: float = 1.5

func can_spawn() -> bool:
	for player in get_tree().get_nodes_in_group("player"):
		if global_position.distance_squared_to(player.global_position) < minimum_player_distance * minimum_player_distance:
			return false
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if global_position.distance_squared_to(enemy.global_position) < minimum_enemy_distance * minimum_enemy_distance:
			return false
	return test_light() < 0.03

func test_light() -> float:
	# Test light volumes on the CPU instead of synchronous GPU image readback.
	var sample_position = global_position + Vector3.UP * 0.5
	for light: Light3D in get_tree().get_nodes_in_group("spawn_blocking_light"):
		if not light.is_visible_in_tree() or light.light_energy <= 0.0:
			continue
		var offset = sample_position - light.global_position
		var distance = offset.length()
		var light_range = light.spot_range if light is SpotLight3D else light.omni_range
		if distance >= light_range or (light.light_cull_mask & 512) == 0:
			continue
		if light is SpotLight3D:
			var facing = -light.global_basis.z.normalized()
			if distance > 0.001 and facing.dot(offset / distance) < cos(deg_to_rad(light.spot_angle)):
				continue
		var ray = PhysicsRayQueryParameters3D.create(light.global_position, sample_position, 1)
		if not get_world_3d().direct_space_state.intersect_ray(ray).is_empty():
			continue
		return 1.0
	return 0.0
