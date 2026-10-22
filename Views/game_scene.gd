extends Node3D

@export var player: PackedScene
@export var crate: PackedScene
var wave_running = false
var game_over = false
var shake_tween: Tween
var camera_rest_rotation = Vector3.ZERO
@onready var hud = get_tree().get_first_node_in_group("hud")

func _ready():
	MetaData.apply_graphics(get_viewport(), $WorldEnvironment.environment)
	Audio.set_loop(preload("res://Assets/Music/Dayloop.ogg"))
	spawn_players()
	for light in find_children("*", "Light3D", true, false):
		if light is SpotLight3D or light is OmniLight3D:
			light.add_to_group("spawn_blocking_light")
	camera_rest_rotation = get_viewport().get_camera_3d().rotation

func _physics_process(_delta):
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
	if Input.is_action_just_pressed("debug_button") and not wave_running and not game_over:
		start_wave()

func spawn_players():
	var index = 0
	for device in MetaData.players:
		var instance = player.instantiate()
		instance.player_id = device + 1
		instance.position = Vector3((index % 2) * 1.5, 1, (index / 2) * 1.5)
		add_child(instance)
		index += 1

func day_to_night():
	$AnimationPlayer.play("DayToNight")
	Audio.next_song = preload("res://Assets/Music/Zombietheme3.ogg")

func night_to_day():
	$AnimationPlayer.play_backwards("DayToNight")
	get_tree().call_group("enemy", "delete")

func check_lose_condition():
	if get_tree().get_nodes_in_group("player").is_empty():
		lose()

func lose():
	if game_over:
		return
	game_over = true
	wave_running = false
	$EnemySpawner.stop_wave()
	hud.lose()
	get_tree().paused = true

func shake_camera():
	var camera = get_viewport().get_camera_3d()
	if not is_instance_valid(camera):
		return
	if shake_tween and shake_tween.is_valid():
		shake_tween.kill()
	shake_tween = create_tween()
	var offset = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)) * 0.017
	shake_tween.tween_property(camera, "rotation", camera_rest_rotation + offset, 0.1)
	shake_tween.tween_property(camera, "rotation", camera_rest_rotation, 0.3)

func spawn_rocket_crate():
	spawn_supply(preload("res://Entities/RocketCrate.tscn"))

func spawn_bullet_crate():
	spawn_supply(crate)

func spawn_supply(packed: PackedScene):
	var instance = packed.instantiate()
	instance.closed = false
	instance.position = Vector3(randf_range(-20, 20), randf_range(20, 30), randf_range(-20, 20))
	add_child(instance)

func end_wave():
	if not wave_running or game_over:
		return
	$EnemySpawner.stop_wave()
	wave_running = false
	MetaData.wave_number += 1
	night_to_day()
	hud.end_wave()

func start_wave():
	if wave_running or game_over:
		return
	wave_running = true
	day_to_night()
	$EnemySpawner.start_wave()
	hud.start_wave()

func _on_enemy_spawner_timer_timeout():
	end_wave()
