extends Node3D


func _ready():
	MetaData.add_decal(self)
	var lifetime = Timer.new()
	lifetime.one_shot = true
	lifetime.timeout.connect(queue_free)
	add_child(lifetime)
	lifetime.start(20.0)

func _exit_tree():
	MetaData.decals.erase(self)
