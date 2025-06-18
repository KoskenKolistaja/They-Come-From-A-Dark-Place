extends RigidBody3D

#@export var contents: PackedScene

#var weapons: Array[String] = ["uzi","bat","revolver","bazooka"]

var closed = true

#var bullets = false
@export var hand_item: PackedScene

@export var info_label: PackedScene

@export var text: String

#func _ready():
	#if randf() > 0.5:
		#bullets = true
		#set_pic()
	#else:
		#bullets = false
		#set_pic()


func _physics_process(delta):
	if not closed:
		$parachute.show()
		if $RayCast3D.is_colliding():
			$parachute/AnimationPlayer.play("put_down")
			closed = true


func set_gravity():
	linear_damp = 0.0
	gravity_scale = 1
	axis_lock_angular_x = false
	axis_lock_angular_y = false
	axis_lock_angular_z = false


#func set_pic():
	#var pic1: MeshInstance3D = $MeshInstance3D2/pic1
	#var pic2: MeshInstance3D = $MeshInstance3D3/pic2
	#
	#var mat1: StandardMaterial3D = pic1.get_surface_override_material(0)
	#
#
	#
	#if bullets:
		#mat1.albedo_texture = preload("res://Assets/UI Textures/Bullet.png")
	#else:
		#mat1.albedo_texture = preload("res://Assets/UI Textures/Rocket.png")


#func _ready():
	#if not contents:
		#set_random_content()

#func set_random_content():
	#var randi = randi_range(0,weapons.size()-1)
	#contents = MetaData.weapons[weapons[randi]]

#func spawn_content():
	#var item_instance = contents.instantiate()
	#item_instance.global_transform = $weapon_spot.global_transform
	#get_tree().current_scene.add_child(item_instance)
	#queue_free()

#func get_hit():
	#if contents:
		#spawn_content()


#func _on_area_3d_body_entered(body):
	#if body.is_in_group("player"):
		#if bullets:
			#body.bullets += 100
			#spawn_info_label("+100",1)
		#else:
			#body.rockets += 10
			#spawn_info_label("+10",2)
		#
		#body.update_hud_ammo()
		#queue_free()


func action(caller):
	
	caller.get_parent().rockets += 10
	spawn_info_label("+10",2)

	caller.get_parent().update_hud_ammo()
	queue_free()


func spawn_info_label(text,type: int,time: float = 2.0):
	var label_instance = info_label.instantiate()
	if type:
		label_instance.type = type
		print(label_instance.type)
	label_instance.text = text
	label_instance.time = time
	get_tree().current_scene.add_child(label_instance)
	label_instance.global_position = $MeshInstance3D.global_position
