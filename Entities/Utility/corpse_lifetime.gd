extends Node3D

func _ready():
	MetaData.add_ragdoll(self)
	$metarig/Skeleton3D/PhysicalBoneSimulator3D.physical_bones_start_simulation()
	var lifetime = Timer.new()
	lifetime.one_shot = true
	lifetime.timeout.connect(queue_free)
	add_child(lifetime)
	lifetime.start(12.0)

func _exit_tree():
	MetaData.delete_ragdoll(self)
