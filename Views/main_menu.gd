extends Control




func _ready():
	$Base/VBoxContainer/StartButton.grab_focus()
	Audio.assign_song(preload("res://Assets/Music/Zombieluonnos2.ogg"),-12)


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Views/character_selection.tscn")


func _on_settings_button_pressed():
	$Base.hide()
	$Settings.show()


func _on_quit_button_pressed():
	get_tree().quit()


func _on_option_button_item_selected(index):
	var viewport_rid = get_tree().root.get_viewport_rid()

	match index:
		0:  # No AA
			RenderingServer.viewport_set_msaa_3d(viewport_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
		1:  # FXAA
			RenderingServer.viewport_set_msaa_3d(viewport_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
		2:  # MSAA 2x
			RenderingServer.viewport_set_msaa_3d(viewport_rid, RenderingServer.VIEWPORT_MSAA_2X)
		3:  # MSAA 4x
			RenderingServer.viewport_set_msaa_3d(viewport_rid, RenderingServer.VIEWPORT_MSAA_4X)
		4:  # MSAA 8x
			RenderingServer.viewport_set_msaa_3d(viewport_rid, RenderingServer.VIEWPORT_MSAA_8X)


func _on_back_button_pressed():
	$Settings.hide()
	$Base.show()
	$Base/VBoxContainer/StartButton.grab_focus()


func _on_spin_box_value_changed(value):
	MetaData.max_ragdolls = value
