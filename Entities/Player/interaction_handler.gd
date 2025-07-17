extends Area3D

var interactables: Array



func _physics_process(delta):
	if get_parent().dead:
		return
	
	if interactables:
		$Label.show()
		
		var interactable = interactables[0]
		
		if interactable.text:
			$Label.text = interactable.text
		
		var camera: Camera3D = get_viewport().get_camera_3d()
		
		var twod_position = camera.unproject_position(interactable.global_position)
		
		$Label.global_position = twod_position
		
		
		if Input.is_action_just_pressed("p%d_interact" % get_parent().player_id):
			interactable.action(self)
			return
		
	else:
		$Label.hide()


func get_closest():
	pass

func hide_label():
	$Label.hide()

func get_money() -> int:
	return get_parent().money

func set_money(amount):
	get_parent().money = amount

func update_money():
	get_parent().update_hud_money()

func _on_body_entered(body):
	if body.is_in_group("interactable"):
		interactables.append(body)


func _on_body_exited(body):
	interactables.erase(body)
