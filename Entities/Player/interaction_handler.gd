extends Area3D

var interactables: Array = []

func _physics_process(_delta):
	if get_parent().dead:
		hide_label()
		return
	interactables = interactables.filter(func(item): return is_instance_valid(item) and not item.is_queued_for_deletion() and item.is_in_group("interactable"))
	var interactable = get_closest()
	if interactable == null:
		hide_label()
		return
	var camera = get_viewport().get_camera_3d()
	if camera == null or camera.is_position_behind(interactable.global_position):
		hide_label()
		return
	$Label.show()
	$Label.text = interactable.text
	$Label.global_position = camera.unproject_position(interactable.global_position)
	if Input.is_action_just_pressed("p%d_interact" % get_parent().player_id):
		interactable.action(self)

func get_closest():
	var closest = null
	var distance = INF
	for item in interactables:
		var candidate = global_position.distance_squared_to(item.global_position)
		if candidate < distance:
			distance = candidate
			closest = item
	return closest

func hide_label():
	$Label.hide()

func get_money() -> int:
	return get_parent().money

func set_money(amount):
	get_parent().money = amount

func update_money():
	get_parent().update_hud_money()

func _on_body_entered(body):
	if body.is_in_group("interactable") and not interactables.has(body):
		interactables.append(body)

func _on_body_exited(body):
	interactables.erase(body)
