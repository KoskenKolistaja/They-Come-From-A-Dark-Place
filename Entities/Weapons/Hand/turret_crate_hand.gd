extends Node3D


var type = "turret_crate"

var player

var left = false


@export var turret: PackedScene


var placeable = false

@export var denied_color: Color
@export var accepted_color: Color



@onready var mat:StandardMaterial3D = $Hologram.get_surface_override_material(0)



func _ready():
	pass



func _physics_process(delta):
	if $Handle/RayCast3D.is_colliding():
		$Hologram.show()
		$Hologram.global_position = $Handle/RayCast3D.get_collision_point()
		
		var bodies = $Hologram/Area3D.get_overlapping_bodies()
		
		
		if bodies:
			set_hologram_color(denied_color)
			placeable = false
		else:
			set_hologram_color(accepted_color)
			placeable = true
		
	else:
		$Hologram.hide()


func set_hologram_color(color):
	mat.set_albedo(color)
	#mat.set_emission(color)



func action():
	if placeable:
		spawn_turret()
		if left:
			player.clear_left_hand()
		else:
			player.clear_right_hand()


func spawn_turret():
	var turret_instance = turret.instantiate()
	get_tree().current_scene.add_child(turret_instance)
	turret_instance.global_position = $Handle/RayCast3D.get_collision_point()
