extends Control


@export var player_hud: PackedScene

#Data is accessed with players id
var player_data_bank = {}

var frozen= false





func freeze():
	var list = get_tree().get_nodes_in_group("freezable")
	
	
	if not frozen:
		for item in list:
			item.set_physics_process(false)
	else:
		for item in list:
			item.set_physics_process(false)


func _physics_process(delta):
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused:
			get_tree().paused = false
		else:
			get_tree().paused = true
			$PauseMenu.show()
			$PauseMenu/HBoxContainer/ContinueButton.grab_focus()

func set_texture(exported_texture):
	$TextureRect.texture = exported_texture


func _ready():
	await get_tree().physics_frame
	spawn_player_huds()

func update_zombies(number):
	$WaveNumber/HBoxContainer/TextureRect/ZombiesNumber.text = str(number)

func update_heavytaurs(number):
	$WaveNumber/HBoxContainer/TextureRect2/HeavytaursNumber.text = str(number)

func end_wave():
	$WaveNumber.hide()
	$ReadyUp.show()

func start_wave():
	$WaveNumber.text = "WAVE " + str(MetaData.wave_number)
	$WaveNumber.show()
	$ReadyUp.hide()


func update_money(player_id,amount):
	var huds = $HBoxContainer.get_children()
	
	for hud in huds:
		
		if hud.player_id == player_id:
			hud.update_money(amount)

func update_ammo(player_id : int, ammo_numbers : Dictionary):
	var huds = $HBoxContainer.get_children()
	
	
	
	for hud in huds:
		
		if hud.player_id == player_id:
			hud.update_bullets(ammo_numbers["bullets"])
			hud.update_rockets(ammo_numbers["rockets"])

func update_health(player_id : int, health_amount : int):
	var huds = $HBoxContainer.get_children()
	
	
	
	for hud in huds:
		
		if hud.player_id == player_id:
			hud.update_health(health_amount)



func spawn_player_huds():
	var players = get_tree().get_nodes_in_group("player")
	
	
	for p in players:
		var player_data = {
			"player" : p,
			"id": p.player_id
			}
		
		var hud_instance = player_hud.instantiate()
		$HBoxContainer.add_child(hud_instance)
		hud_instance.player_id = p.player_id
		hud_instance.update_name(p.player_id)


func _on_continue_button_pressed():
	get_tree().paused = false
	$PauseMenu.hide()


func _on_quit_button_pressed():
	get_tree().quit()


func _on_back_to_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Views/main_menu.tscn")
