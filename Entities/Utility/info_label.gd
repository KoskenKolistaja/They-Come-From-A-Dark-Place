extends Node3D

var time = 2
var text
var type


func _ready():
	
	if text:
		$Label3D.text = text
	
	
	if type:
		set_pic()
		$Label3D/Picture.show()
	
	
	
	
	
	
	
	await get_tree().create_timer(time).timeout
	queue_free()



func set_pic():
	var pic1: MeshInstance3D = $Label3D/Picture
	
	var mat1: StandardMaterial3D = pic1.get_surface_override_material(0)
	
	
	if type == 1:
		mat1.albedo_texture = preload("res://Assets/UI Textures/Bullet.png")
	elif type == 2:
		mat1.albedo_texture = preload("res://Assets/UI Textures/Rocket.png")
	else:
		mat1.albedo_texture = preload("res://Assets/UI Textures/Cross.png")
		mat1.albedo_color = Color(1,0,0)


func _physics_process(delta):
	global_position += Vector3.UP * 0.01
	
	
	var camera = get_viewport().get_camera_3d()
	
	look_at(camera.global_position)
