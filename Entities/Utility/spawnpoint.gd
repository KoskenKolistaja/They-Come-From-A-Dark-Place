extends Node3D

@export var light_detector: PackedScene





func _physics_process(delta):
	if Input.is_action_just_pressed("down"):
		test_light()


func _ready():
	test_light()


func test_light():
	var light_level
	
	$LightDetector.global_transform.origin = self.global_position
	
	light_level = $LightDetector.get_light_level()
	
	print(light_level)
	
	
	return light_level
