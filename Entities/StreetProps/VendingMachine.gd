extends StaticBody3D

@export var text: String

@export var weapon: PackedScene

@export var price: int


@onready var light = $"../SpotLight3D"





func action(caller):
	var money_amount = caller.get_money()
	
	if money_amount >= price:
		var uzi_instance = weapon.instantiate()
		get_tree().current_scene.add_child(uzi_instance)
		uzi_instance.rotation = $SpawnSpot.rotation
		uzi_instance.global_position = $SpawnSpot.global_position
		
		money_amount -= price
		caller.set_money(money_amount)
		caller.update_money()
		
		$AudioStreamPlayer.play()
