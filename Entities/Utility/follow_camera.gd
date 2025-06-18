extends Node3D

var movement_vector = Vector3.ZERO


func _physics_process(delta):
	var players = get_tree().get_nodes_in_group("player")
	var center_point: Vector3
	var longest_length: float
	
	var desired: Vector3
	
	if players:
		center_point = get_center_point(players)
	else:
		return
	
	
	longest_length = get_longest_length(players,center_point)
	
	desired = center_point
	
	var ratio = (desired - self.global_position).length()
	
	
	movement_vector = movement_vector.move_toward(desired,ratio*0.01)
	
	self.global_position = movement_vector


func get_longest_length(players: Array, point):
	var total = 0
	var longest = (players[0].global_position - point).length()
	
	for p in players:
		var distance = (p.global_position - point).length()
		if distance > longest:
			longest = distance
	
	return longest

func get_center_point(nodes: Array) -> Vector3:
	if nodes.is_empty():
		return Vector3.ZERO
	var total = Vector3.ZERO
	for node in nodes:
		if node is Node3D:
			total += node.global_transform.origin
	return total / nodes.size()
