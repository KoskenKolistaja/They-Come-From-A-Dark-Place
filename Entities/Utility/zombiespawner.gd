extends Node3D

@export var zombie: PackedScene

@export var heavytaur: PackedScene

var active = false


func _ready():
	$Timer.wait_time = randf_range(1,2)
	$Timer2.wait_time = randf_range(490,1000)

func set_active(boolean: bool):
	if boolean:
		active = true
	else:
		active = false



func _on_timer_timeout():
	if active:
		spawn_zombie()

func _on_timer_2_timeout():
	if active:
		spawn_heavytaur()


func spawn_zombie():
	var zombie_instance = zombie.instantiate()
	get_tree().current_scene.add_child(zombie_instance)
	zombie_instance.global_position = self.global_position

func spawn_heavytaur():
	var zombie_instance = heavytaur.instantiate()
	get_tree().current_scene.add_child(zombie_instance)
	zombie_instance.global_position = self.global_position
