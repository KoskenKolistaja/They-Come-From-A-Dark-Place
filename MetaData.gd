extends Node


var players = []

var wave_number = 2

var zombie_waves = [0,50,75,100,150,200,300,400,500,750,1000,1100,1200,1300,1400,1500,1600,1700,1800,1900]
var heavytaur_waves = [0,0,0,0,0,0,1,1,1,1,2,4,6,10,12,15,20,22,26,40,60,100]


var anti_aliasing: int = 0

var max_ragdolls = 2

var ragdolls = []

var revolver = preload("res://Entities/Weapons/Physical/revolver_physical.tscn")
var bat = preload("res://Entities/Weapons/Physical/bat_physical.tscn")
var uzi = preload("res://Entities/Weapons/Physical/uzi_physical.tscn")
var bazooka = preload("res://Entities/Weapons/Physical/bazooka_physical.tscn")
var bullet_crate = preload("res://Entities/BulletCrate.tscn")
var rocket_crate = preload("res://Entities/RocketCrate.tscn")
var turret_crate = preload("res://Entities/TurretCrate.tscn")
var health_crate = preload("res://Entities/HealthCrate.tscn")


var weapons = {
	"revolver": revolver,
	"bat": bat,
	"uzi": uzi,
	"bazooka": bazooka,
	"bullet_crate": bullet_crate,
	"rocket_crate": rocket_crate,
	"turret_crate": turret_crate,
	"health_crate": health_crate
}


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func add_ragdoll(ragdoll):
	ragdolls.append(ragdoll)
	
	var list_size = ragdolls.size()
	
	if list_size > MetaData.max_ragdolls:
		var ragdoll_to_be_erased = ragdolls[0]
		ragdolls.erase(ragdoll_to_be_erased)
		ragdoll_to_be_erased.queue_free()

func delete_ragdoll(ragdoll):
	ragdolls.erase(ragdoll)
