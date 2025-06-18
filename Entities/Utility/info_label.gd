extends Node3D

var time = 2
var text
var type


func _ready():
	
	if text:
		$Label3D.text = text
	
	
	if type:
		$Label3D/Picture.show()
		if type == 1:
			set_pic(true)
			print("mentii bulletiin")
		elif type == 2:
			set_pic(false)
			print("mentii rockettii")
	
	
	
	
	
	
	
	await get_tree().create_timer(time).timeout
	queue_free()



func set_pic(bullets: bool):
	var pic1: MeshInstance3D = $Label3D/Picture
	
	var mat1: StandardMaterial3D = pic1.get_surface_override_material(0)
	
	
	if bullets:
		mat1.albedo_texture = preload("res://Assets/UI Textures/Bullet.png")
	else:
		mat1.albedo_texture = preload("res://Assets/UI Textures/Rocket.png")


func _physics_process(delta):
	global_position += Vector3.UP * 0.01
	
	
	var camera = get_viewport().get_camera_3d()
	
	look_at(camera.global_position)
