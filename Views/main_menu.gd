extends Control




func _ready():
	$Panel/VBoxContainer/StartButton.grab_focus()
	Audio.assign_song(preload("res://Assets/Music/Zombieluonnos2.ogg"),-12)


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Views/character_selection.tscn")


func _on_settings_button_pressed():
	pass # Replace with function body.


func _on_quit_button_pressed():
	get_tree().quit()
