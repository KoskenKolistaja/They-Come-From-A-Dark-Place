extends Node3D

var player_id = null

var ready_up = false




func _physics_process(delta):
	pass



func set_ready(exported_bool: bool = true):
	if exported_bool:
		$Label3D.show()
		ready_up = true
	else:
		$Label3D.hide()
		ready_up = false
