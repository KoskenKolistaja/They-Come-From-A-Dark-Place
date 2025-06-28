extends StaticBody3D

@export var info_label: PackedScene


@export var text: String

@export var type: int


var price = 100



func action(caller):
	
	
	var money_amount = caller.get_money()
	
	if money_amount >= price:
		var player = caller.get_parent() 
		
		
		
		
		money_amount -= price
		caller.set_money(money_amount)
		
		
		if type == 1:
			player.bullets += 100
			spawn_info_label("+100")
		else:
			player.rockets += 100
			spawn_info_label("+10")
		player.update_hud_ammo()
		player.update_hud_money()
		
		$AudioStreamPlayer.play()

func spawn_info_label(text,time: float = 2.0):
	var label_instance = info_label.instantiate()
	if type:
		label_instance.type = type
	label_instance.text = text
	label_instance.time = time
	get_tree().current_scene.add_child(label_instance)
	label_instance.global_position = $InfoPos.global_position


#func spawn_crate(spawn_position):
	#var crate_instance = crate.instantiate()
	#crate_instance.closed = false
	#get_tree().current_scene.add_child(crate_instance)
	#crate_instance.global_position = spawn_position
