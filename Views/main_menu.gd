extends Control




func _ready():
	$Base/VBoxContainer/StartButton.grab_focus()
	generate_input_map()


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Views/character_selection.tscn")


func _on_settings_button_pressed():
	$Base.hide()
	$Settings.show()
	$Settings/BackButton.grab_focus()

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




func generate_input_map():
	var input_map = InputMap

	# Define the per-player mappings (Xbox-style layout)
	var base_mappings = {
		"ui_left": JOY_BUTTON_DPAD_LEFT,
		"ui_right": JOY_BUTTON_DPAD_RIGHT,
		"interact": JOY_BUTTON_Y,
		"jump": JOY_BUTTON_A,
		"pickup_left": JOY_BUTTON_LEFT_SHOULDER,   # LB
		"pickup_right": JOY_BUTTON_RIGHT_SHOULDER, # RB
	}

	# Loop through 4 players
	for player_id in range(1, 5):  # 1 → 4
		for suffix in base_mappings.keys():
			var action_name = "p%d_%s" % [player_id, suffix]

			# Create action if missing
			if not input_map.has_action(action_name):
				input_map.add_action(action_name)

			# Clear existing events
			input_map.action_erase_events(action_name)

			# Create event
			var event = InputEventJoypadButton.new()
			event.button_index = base_mappings[suffix]
			event.device = player_id - 1   # Device 0 = P1, 1 = P2, etc.
			input_map.action_add_event(action_name, event)
