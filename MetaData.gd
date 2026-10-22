extends Node


var players: Array = []

var wave_number = 1

var zombie_waves = [0,50,75,100,150,200,300,400,500,750,1000,1100,1200,1300,1400,1500,1600,1700,1800,1900]
var heavytaur_waves = [0,0,0,0,0,0,1,1,1,1,2,4,6,10,12,15,20,22,26,40,60,100]
var zombie_dog_waves = [0,1,2,5,10,15,20,35,40,45,50,55,60,65,70,75,80,85]

var anti_aliasing: int = 2
var graphics_quality: int = 1

var max_ragdolls = 20

var ragdolls = []
var decals: Array[Node] = []
const MAX_DECALS = 96

var character_skins = {}

var revolver = preload("res://Entities/Weapons/Physical/revolver_physical.tscn")
var bat = preload("res://Entities/Weapons/Physical/bat_physical.tscn")
var uzi = preload("res://Entities/Weapons/Physical/uzi_physical.tscn")
var bazooka = preload("res://Entities/Weapons/Physical/bazooka_physical.tscn")
var bullet_crate = preload("res://Entities/BulletCrate.tscn")
var rocket_crate = preload("res://Entities/RocketCrate.tscn")
var health_crate = preload("res://Entities/HealthCrate.tscn")

var suitman = preload("res://Entities/Player/Characters/suitman.tscn")
var lara = preload("res://Entities/Player/Characters/lara.tscn")
var hazmat = preload("res://Entities/Player/Characters/hazmat.tscn")
var swat = preload("res://Entities/Player/Characters/swat.tscn")


var weapons = {
	"revolver": revolver,
	"bat": bat,
	"uzi": uzi,
	"bazooka": bazooka,
	"bullet_crate": bullet_crate,
	"rocket_crate": rocket_crate,
	"health_crate": health_crate
}

var characters = {
	"suitman": suitman,
	"lara": lara,
	"hazmat": hazmat,
	"swat": swat
}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func add_ragdoll(ragdoll):
	ragdolls = ragdolls.filter(func(item): return is_instance_valid(item) and not item.is_queued_for_deletion())
	ragdolls.append(ragdoll)
	
	while ragdolls.size() > max_ragdolls:
		var ragdoll_to_be_erased = ragdolls.pop_front()
		
		if is_instance_valid(ragdoll_to_be_erased):
			ragdoll_to_be_erased.queue_free()

func delete_ragdoll(ragdoll):
	ragdolls.erase(ragdoll)

func reset_run():
	wave_number = 1
	players.clear()
	character_skins.clear()
	ragdolls.clear()
	decals.clear()

func add_decal(decal: Node):
	decals = decals.filter(func(item): return is_instance_valid(item) and not item.is_queued_for_deletion())
	decals.append(decal)
	while decals.size() > MAX_DECALS:
		var oldest = decals.pop_front()
		if is_instance_valid(oldest):
			oldest.queue_free()

func apply_graphics(viewport: Viewport, environment: Environment = null):
	viewport.scaling_3d_scale = 0.75 if graphics_quality == 0 else 1.0
	var msaa_modes = [Viewport.MSAA_DISABLED, Viewport.MSAA_DISABLED, Viewport.MSAA_2X, Viewport.MSAA_4X, Viewport.MSAA_8X]
	viewport.msaa_3d = msaa_modes[anti_aliasing]
	viewport.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if anti_aliasing == 1 else Viewport.SCREEN_SPACE_AA_DISABLED
	if environment != null:
		environment.ssr_enabled = graphics_quality == 2
		environment.ssil_enabled = graphics_quality == 2
		environment.ssao_enabled = graphics_quality >= 1
		environment.volumetric_fog_enabled = graphics_quality >= 1
