extends Node3D

var loaded = true

var type = "bazooka"

var player

var left = false

@export var rocket: PackedScene



func action():
	if loaded and player.rockets > 0:
		#$AnimationPlayer.play("shoot")
		#$AudioStreamPlayer.play()
		loaded = false
		$Timer.start()
		spawn_rocket()
		player.rockets -= 1
		player.update_hud_ammo()

func spawn_rocket():
	var rocket_instance = rocket.instantiate()
	rocket_instance.rotation = $Handle.rotation
	
	var direction = -global_transform.basis.z
	
	rocket_instance.direction = direction
	
	rocket_instance.player = player
	
	get_tree().current_scene.add_child(rocket_instance)
	rocket_instance.global_position = $Handle/Cylinder/barrel.global_position

func _on_timer_timeout():
	loaded = true
