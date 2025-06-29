extends Node3D

var players := {}

var id_list = []

var button = 0

@export var character: PackedScene

@onready var spots = [
	$Spot1,
	$Spot2,
	$Spot3,
	$Spot4,
	$Spot5,
	$Spot6,
	$Spot7,
]


func _ready():
	Audio.assign_song(preload("res://Assets/Music/ChooseYourFighter.ogg"))
	DebugBall.hide()

func _input(event):
	if not players.has(event.device):
		if Input.is_joy_button_pressed(event.device,JOY_BUTTON_A):
			spawn_character(event.device)
			id_list.append(event.device)
	elif Input.is_joy_button_pressed(event.device,JOY_BUTTON_A) and event.is_pressed():
		
		if players[event.device].ready_up:
			if is_game_ready():
				start_game()
		else:
			players[event.device].set_ready()
	elif Input.is_joy_button_pressed(event.device,JOY_BUTTON_B):
		delete_character(event.device)
	


func shake_camera():
	pass

func _process(delta):
	for device in id_list:
		var id_str := "p%d" % (device + 1)
		if Input.is_action_just_pressed("%s_ui_left" % id_str):
			players[device].previous_character(device+1)
		elif Input.is_action_just_pressed("%s_ui_right" % id_str):
			players[device].next_character(device+1)

func start_game():
	MetaData.players = id_list
	get_tree().change_scene_to_file("res://Views/GameScene.tscn")

func is_game_ready():
	var returned = true
	
	for item in id_list:
		if not players[item].ready_up:
			returned = false
			break
	
	
	return returned



func spawn_character(player_id):
	var character_instance = character.instantiate()
	var free_spot = get_first_free()
	free_spot.add_child(character_instance)
	
	
	players[player_id] = character_instance
	character_instance.player_id = player_id + 1
	


func delete_character(id):
	
	players[id].queue_free()
	players.erase(id)
	
	id_list.erase(id)

func get_first_free():
	var free = null
	
	
	for item in spots:
		if not item.get_children():
			free = item
			return free
