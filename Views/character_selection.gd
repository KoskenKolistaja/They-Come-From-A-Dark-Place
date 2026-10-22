extends Node3D

var players := {}

var id_list = []

var button = 0

@export var character: PackedScene

@export var ui_switch: AudioStream
@export var ui_accept: AudioStream


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
	#Audio.assign_song(preload("res://Assets/Music/ChooseYourFighter.ogg"))
	DebugBall.hide()
	MetaData.character_skins.clear()

func _input(event):
	if not event is InputEventJoypadButton or not event.pressed:
		return
	if event.device < 0 or event.device >= 4:
		return
	if not players.has(event.device):
		if event.button_index == JOY_BUTTON_A and players.size() < 4:
			spawn_character(event.device)
			id_list.append(event.device)
			Audio.assign_sound(ui_switch,-6)
	elif event.button_index == JOY_BUTTON_A:
		Audio.assign_sound(ui_accept,-15)
		if players[event.device].ready_up:
			if is_game_ready():
				start_game()
		else:
			players[event.device].set_ready()
			Audio.assign_sound(ui_accept)
	elif event.button_index == JOY_BUTTON_B:
		delete_character(event.device)
		Audio.assign_sound(ui_switch,-6)
	


func shake_camera():
	pass

func _process(delta):
	for device in id_list:
		var id_str := "p%d" % (device + 1)
		if Input.is_action_just_pressed("%s_ui_left" % id_str):
			players[device].previous_character(device+1)
			Audio.assign_sound(ui_switch,-6)
		elif Input.is_action_just_pressed("%s_ui_right" % id_str):
			players[device].next_character(device+1)
			Audio.assign_sound(ui_switch,-6)



func start_game():
	MetaData.players = id_list.duplicate()
	MetaData.wave_number = 1
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
	if free_spot == null:
		character_instance.free()
		return
	character_instance.player_id = player_id + 1
	free_spot.add_child(character_instance)
	
	
	players[player_id] = character_instance
	


func delete_character(id):
	
	players[id].queue_free()
	players.erase(id)
	
	id_list.erase(id)
	MetaData.character_skins.erase(id + 1)

func get_first_free():
	var free = null
	
	
	for item in spots:
		if not item.get_children():
			free = item
			return free
