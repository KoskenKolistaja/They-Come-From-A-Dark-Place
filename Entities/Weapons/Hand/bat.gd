extends Node3D


var loaded = true

var type = "bat"

var hitting = false

var player

var left = false

func _physics_process(delta):
	if hitting:
		check_for_hits()


func check_for_hits():
	var bodies = $Handle/Area3D.get_overlapping_bodies()
	
	for item in bodies:
		if item.has_method("get_hit"):
			if item.has_method("store_impact"):
					var dic = {}
					
					var start_point = self.global_position
					var end_point = $Handle/Cube/EndPoint.global_position
					
					dic = {"start_point" : start_point , "end_point" : end_point , "strength" : 10, "killer": player}
					
					
					item.store_impact(dic)
			item.get_hit()
			$AudioStreamPlayer2.play()

func set_hitting(state: bool):
	hitting = state

func action():
	if loaded:
		$AnimationPlayer.play("shoot")
		loaded = false
		$Timer.start()


func _on_timer_timeout():
	loaded = true
