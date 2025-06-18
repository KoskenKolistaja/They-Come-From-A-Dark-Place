extends RigidBody3D


var closed = false



@export var hand_item: PackedScene




func _physics_process(delta):
	if not closed:
		if $RayCast3D.is_colliding():
			$parachute/AnimationPlayer.play("put_down")
			closed = true
	else:
		$parachute.hide()
		set_gravity()

func set_gravity():
	linear_damp = 0.0
	gravity_scale = 1
	axis_lock_angular_x = false
	axis_lock_angular_y = false
	axis_lock_angular_z = false
