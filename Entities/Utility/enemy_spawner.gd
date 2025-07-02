extends Node3D


@export var zombie: PackedScene
@export var heavytaur: PackedScene
@export var zombie_dog: PackedScene


var zombies = 0
var heavytaurs = 0
var zombie_dogs = 0

var current_time = 0
var desired_zombie_time = 5000
var desired_heavytaur_time = 10000
var desired_zombie_dog_time = 10000


@onready var hud = get_tree().get_first_node_in_group("hud")


func _ready():
	current_time = Time.get_ticks_msec()
	$EnemySpawnerTimer.start()
	zombies = MetaData.zombie_waves[MetaData.wave_number]
	hud.update_zombies(zombies)
	hud.update_heavytaurs(heavytaurs)
	hud.update_zombie_dogs(zombie_dogs)

func _physics_process(delta):
	current_time = Time.get_ticks_msec()
	
	if is_nan(desired_zombie_time):
		desired_zombie_time = current_time
	
	if current_time > desired_zombie_time and zombies:
		
		
		spawn_zombie()
		desired_zombie_time = current_time + get_zombie_time()
		
		
		hud.update_zombies(zombies)
	
	if current_time > desired_heavytaur_time and heavytaurs:
		
		
		spawn_heavytaur()
		desired_heavytaur_time = current_time + get_heavytaur_time()
		
		
		hud.update_heavytaurs(heavytaurs)

	if current_time > desired_zombie_dog_time and zombie_dogs:
		
		
		spawn_zombie_dog()
		desired_zombie_dog_time = current_time + get_zombie_dog_time()
		
		
		hud.update_zombie_dogs(zombie_dogs)


func update_enemies():
	zombies = MetaData.zombie_waves[MetaData.wave_number]
	hud.update_zombies(zombies)
	
	heavytaurs = MetaData.heavytaur_waves[MetaData.wave_number]
	hud.update_heavytaurs(heavytaurs)
	
	zombie_dogs = MetaData.zombie_dog_waves[MetaData.wave_number]
	hud.update_zombie_dogs(zombie_dogs)

func get_zombie_time():
	var seconds = $EnemySpawnerTimer.time_left
	
	var average = seconds/zombies
	
	var returned = average + randf_range(-average,average) + 0.01
	
	returned *= 1000
	
	return returned

func get_heavytaur_time():
	var seconds = $EnemySpawnerTimer.time_left
	
	var average = seconds/heavytaurs
	
	var returned = average
	
	returned *= 1000
	
	return returned

func get_zombie_dog_time():
	var seconds = $EnemySpawnerTimer.time_left
	
	var average = seconds/zombie_dogs
	
	var returned = average
	
	returned *= 1000
	
	return returned

func spawn_zombie():
	var points = get_tree().get_nodes_in_group("spawnpoint")
	
	var size = points.size()
	var random = randi_range(1,size)
	var rand_index = random-1
	var point = points[rand_index]
	
	if point.test_light() < 0.01:
		var zombie_instance = zombie.instantiate()
		
		get_tree().current_scene.add_child(zombie_instance)
		zombie_instance.global_position = point.global_position
		
		zombies -= 1
		
		if zombies <= 0:
			desired_zombie_time = 0
	else:
		desired_zombie_time = 0

func spawn_heavytaur():
	var points = get_tree().get_nodes_in_group("spawnpoint")
	
	var size = points.size()
	var random = randi_range(1,size)
	var rand_index = random-1
	var point = points[rand_index]
	
	if point.test_light() < 0.01:
		var heavytaur_instance = heavytaur.instantiate()
		
		get_tree().current_scene.add_child(heavytaur_instance)
		heavytaur_instance.global_position = point.global_position
		
		heavytaurs -= 1
		
		if heavytaurs <= 0:
			desired_heavytaur_time = 0
	else:
		desired_heavytaur_time = 0

func spawn_zombie_dog():
	
	var points = get_tree().get_nodes_in_group("spawnpoint")
	
	var size = points.size()
	var random = randi_range(1,size)
	var rand_index = random-1
	var point = points[rand_index]
	
	if point.test_light() < 0.01:
		var zombie_dog_instance = zombie_dog.instantiate()
		
		get_tree().current_scene.add_child(zombie_dog_instance)
		zombie_dog_instance.global_position = point.global_position
		
		
		zombie_dogs -= 1
		
		if zombie_dogs <= 0:
			desired_zombie_dog_time = 0
	else:
		desired_zombie_dog_time = 0
