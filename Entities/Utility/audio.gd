extends Control



var next_song: AudioStream





#var soundbanks = {
	#"z_death": [
		#preload("res://Assets/SFX/ZombieSFX/death1.ogg"),
		#preload("res://Assets/SFX/ZombieSFX/death2.ogg"),
		#preload("res://Assets/SFX/ZombieSFX/death3.ogg"),
		#preload("res://Assets/SFX/ZombieSFX/death4.ogg"),
		#preload("res://Assets/SFX/ZombieSFX/death5.ogg"),
		#preload("res://Assets/SFX/ZombieSFX/death6.ogg"),
		#preload("res://Assets/SFX/ZombieSFX/death7.ogg"),
		#],
	#"z_idle": [
		#preload("res://Assets/SFX/ZombieSFX/idle1.ogg"),
		#preload("res://Assets/SFX/ZombieSFX/idle2.ogg"),
		#preload("res://Assets/SFX/ZombieSFX/idle3.ogg"),
		#preload("res://Assets/SFX/ZombieSFX/idle4.ogg"),
		#preload("res://Assets/SFX/ZombieSFX/idle5.ogg"),
		#preload("res://Assets/SFX/ZombieSFX/idle6.ogg"),
		#preload("res://Assets/SFX/ZombieSFX/idle7.ogg"),
	#]
#}

var sfx_players

var looping = false


func _process(delta):
	
	if looping:
		if next_song:
			if not $Music.playing:
				$Music.stream = next_song
				$Music.play()
				looping = false
		elif not $Music.playing:
			$Music.play()
	elif not $Music.playing:
		next_song = null
		looping = true
		$Music.stream = preload("res://Assets/Music/Dayloop.ogg")
		
		#get_tree().current_scene.night_to_day()


func set_loop(song):
	$Music.stream = song
	looping = true

func _ready():
	sfx_players = $SFX.get_children()
	Audio.assign_song(preload("res://Assets/Music/Zombieluonnos2.ogg"),-12)

#func play_random_from(list_name: String):
	#var array: Array = soundbanks[list_name]
	#var random_index: int = randi_range(0,array.size() - 1)
	#var random_sound = array[random_index]
	#
	#assign_sound(random_sound)


func assign_song(song , volume = 0.0):
	var player: AudioStreamPlayer = $Music
	
	player.volume_db = volume
	
	player.stream = song
	player.play()


func assign_sound(sound, volume = 0.0):
	var free_player = null
	for item: AudioStreamPlayer in sfx_players:
		if not item.is_playing():
			free_player = item
			break
	
	if free_player:
		free_player.stream = sound
		free_player.volume_db = volume
		free_player.play()
	else:
		return
