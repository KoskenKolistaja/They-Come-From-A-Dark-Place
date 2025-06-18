extends StaticBody3D

@export var crate: PackedScene

@export var text: String

var price = 100



func action(caller):
	
	
	var money_amount = caller.get_money()
	
	if money_amount >= price:
		var player = caller.global_position
		var player_position = Vector3(player.x+randf_range(-1,1),20,player.z+randf_range(-1,1)) 
		spawn_crate(player_position)
		
		money_amount -= price
		caller.set_money(money_amount)
		caller.update_money()
	




func spawn_crate(spawn_position):
	var crate_instance = crate.instantiate()
	crate_instance.closed = false
	get_tree().current_scene.add_child(crate_instance)
	crate_instance.global_position = spawn_position
