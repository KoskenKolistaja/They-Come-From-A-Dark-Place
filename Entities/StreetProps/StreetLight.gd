extends StaticBody3D

@export var text: String

@onready var light = $"../SpotLight3D"

var price = 50

func _ready():
	light.add_to_group("spawn_blocking_light")


func action(caller):
	if not is_in_group("interactable"):
		return
	var money_amount = caller.get_money()
	
	if money_amount >= price:
		light.show()
		remove_from_group("interactable")
		
		money_amount -= price
		caller.set_money(money_amount)
		caller.update_money()
