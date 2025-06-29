extends Node3D

var player_id = null

var ready_up = false

var character

@export var explosion: PackedScene

var characters = [
	preload("res://Entities/UI Elements/SelectionCharacters/suitman.tscn"),
	preload("res://Entities/UI Elements/SelectionCharacters/lara.tscn"),
	preload("res://Entities/UI Elements/SelectionCharacters/hazmat.tscn"),
	preload("res://Entities/UI Elements/SelectionCharacters/swat.tscn")
]

var key_names = [
	"suitman",
	"lara",
	"hazmat",
	"swat"
]

var index = 0

func _ready():
	play_effects()
	character = $Armature
	
	var suitman = preload("res://Entities/UI Elements/SelectionCharacters/suitman.tscn")
	
	var suitman_instance = suitman.instantiate()
	
	add_child(suitman_instance)
	
	character = suitman_instance
	await get_tree().create_timer(0.1).timeout
	MetaData.character_skins[player_id] = key_names[0]


func _physics_process(delta):
	pass


func previous_character(id):
	play_effects()
	
	index -= 1
	if index < 0:
		index = characters.size() - 1
	
	var character_instance = characters[index].instantiate()
	
	character.queue_free()
	
	add_child(character_instance)
	
	character = character_instance
	
	MetaData.character_skins[id] = key_names[index]

func next_character(id):
	play_effects()
	
	index += 1
	if index > characters.size() - 1:
		index = 0
	
	var character_instance = characters[index].instantiate()
	
	character.queue_free()
	
	add_child(character_instance)
	
	character = character_instance
	MetaData.character_skins[id] = key_names[index]


func play_effects():
	var explosion_instance = explosion.instantiate()
	add_child(explosion_instance)
	explosion_instance.scale = Vector3(0.5,0.5,0.5)


func set_ready(exported_bool: bool = true):
	if exported_bool:
		$Label3D.show()
		ready_up = true
	else:
		$Label3D.hide()
		ready_up = false
