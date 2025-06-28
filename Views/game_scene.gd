extends Node3D


@export var player: PackedScene


@export var crate: PackedScene

var song = preload("res://Assets/Music/Zombietheme2.ogg")

var wave_running = false

@onready var hud = get_tree().get_first_node_in_group("hud")

func _physics_process(delta):
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("debug_button") and not wave_running:
		start_wave()
	
	



func _ready():
	Audio.set_loop(preload("res://Assets/Music/Dayloop.ogg"))
	
	spawn_players()


func spawn_players():
	var players = MetaData.players
	
	
	for p in players:
		var player_instance = player.instantiate()
		add_child(player_instance)
		player_instance.player_id = (players[p]) + 1




#func set_music():
	#var tween = get_tree().create_tween()
	#var bus_index = AudioServer.get_bus_index("DynamicMusic")
	#var effect = AudioServer.get_bus_effect(bus_index, 0)  # Index 0, change if needed
#
	#if effect is AudioEffectLowPassFilter:
		#var filter = effect as AudioEffectLowPassFilter
		#tween.tween_property(
			#filter,
			#"cutoff",
			#20000.0,      # Target cutoff frequency in Hz
			#2.0          # Duration in seconds
		#)
	#else:
		#print("Effect is not a LowPassFilter.")



func day_to_night():
	$AnimationPlayer.play("DayToNight")
	Audio.next_song = preload("res://Assets/Music/Zombietheme3.ogg")


func night_to_day():
	$AnimationPlayer.play_backwards("DayToNight")
	get_tree().call_group("enemy", "delete")


func shake_camera():
	var camera = get_viewport().get_camera_3d()
	
	var tween = create_tween()
	
	var current_rotation = camera.rotation_degrees
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(camera,"rotation_degrees",camera.rotation_degrees+Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1)),0.4)
	tween.tween_property(camera,"rotation_degrees",current_rotation,1)


#func _on_timer_timeout():
	#spawn_bullet_crate()


func spawn_rocket_crate():
	var crate_instance = crate.instantiate()
	crate_instance.closed = false
	add_child(crate_instance)
	
	crate_instance.global_position = Vector3(randi_range(-20,20),randi_range(20,30),randi_range(-20,20))

func spawn_bullet_crate():
	var crate_instance = crate.instantiate()
	crate_instance.closed = false
	add_child(crate_instance)
	
	crate_instance.global_position = Vector3(randi_range(-20,20),randi_range(20,30),randi_range(-20,20))

func end_wave():
	wave_running = false
	MetaData.wave_number += 1
	night_to_day()
	hud.end_wave()

func start_wave():
	wave_running = true
	day_to_night()
	$EnemySpawner.update_enemies()
	$EnemySpawner/EnemySpawnerTimer.wait_time = 206
	$EnemySpawner/EnemySpawnerTimer.start()
	hud.start_wave()



func _on_enemy_spawner_timer_timeout():
	end_wave()
