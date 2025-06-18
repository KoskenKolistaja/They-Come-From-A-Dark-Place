extends RigidBody3D

@export var hand_item: PackedScene

#var ammo = 20000

#func _ready():
	#if ammo == 0:
		#await get_tree().create_timer(5).timeout
		#queue_free()
