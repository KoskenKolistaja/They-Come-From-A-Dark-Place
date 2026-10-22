extends Node3D

@export var zombie: PackedScene
@export var heavytaur: PackedScene
@export var zombie_dog: PackedScene
@export_range(1, 200, 1) var max_active_enemies: int = 80

const RETRY_DELAY = 0.25
const MIN_SPAWN_INTERVAL = 0.1
var zombies = 0
var heavytaurs = 0
var zombie_dogs = 0
var running = false
var spawn_delays = [0.0, 0.0, 0.0]
var points: Array[Node] = []
@onready var hud = get_tree().get_first_node_in_group("hud")

func _ready():
	points = get_tree().get_nodes_in_group("spawnpoint")
	update_hud()
	set_physics_process(false)

func start_wave(duration: float = 206.0):
	update_enemies()
	spawn_delays = [1.0, 2.0, 3.0]
	running = true
	$EnemySpawnerTimer.start(duration)
	set_physics_process(true)

func stop_wave():
	running = false
	$EnemySpawnerTimer.stop()
	set_physics_process(false)

func update_enemies():
	zombies = wave_count(MetaData.zombie_waves)
	heavytaurs = wave_count(MetaData.heavytaur_waves)
	zombie_dogs = wave_count(MetaData.zombie_dog_waves)
	update_hud()

func wave_count(waves: Array) -> int:
	# Continue at the final configured difficulty when a table is exhausted.
	return waves[clampi(MetaData.wave_number, 0, waves.size() - 1)]

func update_hud():
	if is_instance_valid(hud):
		hud.update_zombies(zombies)
		hud.update_heavytaurs(heavytaurs)
		hud.update_zombie_dogs(zombie_dogs)

func _physics_process(delta):
	if not running or $EnemySpawnerTimer.is_stopped():
		return
	for kind in range(3):
		spawn_delays[kind] -= delta
		if remaining(kind) <= 0 or spawn_delays[kind] > 0.0:
			continue
		if get_tree().get_nodes_in_group("enemy").size() >= max_active_enemies:
			spawn_delays[kind] = RETRY_DELAY
			continue
		if not spawn_enemy(kind):
			# Lit or occupied points never consume the wave's remaining enemies.
			spawn_delays[kind] = RETRY_DELAY
			continue
		var count = remaining(kind)
		if count > 0:
			var average = $EnemySpawnerTimer.time_left / float(count)
			spawn_delays[kind] = maxf(MIN_SPAWN_INTERVAL, average * randf_range(0.5, 1.5))
		update_hud()

func remaining(kind: int) -> int:
	return [zombies, heavytaurs, zombie_dogs][kind]

func spawn_enemy(kind: int) -> bool:
	if kind < 0 or kind > 2 or remaining(kind) <= 0 or points.is_empty():
		return false
	var offset = randi_range(0, points.size() - 1)
	var point: Node3D = null
	for index in range(points.size()):
		var candidate = points[(offset + index) % points.size()]
		if is_instance_valid(candidate) and candidate.can_spawn():
			point = candidate
			break
	if point == null:
		return false
	var packed: PackedScene = [zombie, heavytaur, zombie_dog][kind]
	if packed == null:
		return false
	var enemy = packed.instantiate()
	# Position must be correct before _ready and collision queries run.
	enemy.position = get_tree().current_scene.to_local(point.global_position)
	get_tree().current_scene.add_child(enemy)
	match kind:
		0: zombies -= 1
		1: heavytaurs -= 1
		2: zombie_dogs -= 1
	return true

func reserve_zombie():
	if running:
		zombies += 1
		update_hud()
