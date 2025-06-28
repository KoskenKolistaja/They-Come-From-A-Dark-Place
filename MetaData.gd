extends Node


var players = []

var wave_number = 2

var zombie_waves = [0,50,75,100,150,200,300,400,500,750,1000,1100,1200,1300,1400,1500,1600,1700,1800,1900]
var heavytaur_waves = [0,0,0,0,0,0,1,1,1,1,2,4,6,10,12,15,20,22,26,40,60,100]

var revolver = preload("res://Entities/Weapons/Physical/revolver_physical.tscn")
var bat = preload("res://Entities/Weapons/Physical/bat_physical.tscn")
var uzi = preload("res://Entities/Weapons/Physical/uzi_physical.tscn")
var bazooka = preload("res://Entities/Weapons/Physical/bazooka_physical.tscn")
var bullet_crate = preload("res://Entities/BulletCrate.tscn")
var rocket_crate = preload("res://Entities/RocketCrate.tscn")
var turret_crate = preload("res://Entities/TurretCrate.tscn")



var weapons = {
	"revolver": revolver,
	"bat": bat,
	"uzi": uzi,
	"bazooka": bazooka,
	"bullet_crate": bullet_crate,
	"rocket_crate": rocket_crate,
	"turret_crate": turret_crate
}


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


func _physics_process(delta):
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			get_tree().paused = false
		else:
			get_tree().paused = true
