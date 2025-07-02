extends CharacterBody3D


var target

var desired = Vector3.ZERO

const SPEED = 6.0

var boolean = false


func _ready():
	target = get_tree().get_first_node_in_group("player")


func _physics_process(delta):
	if target:
		var distance = (target.global_position - self.global_position).length()
		
		if distance < 5:
			jump()
			$AnimationPlayer.stop()
		else:
			chase()

func jump():
	var vector = (target.global_position + Vector3(0,1,0)) - self.global_position
	
	var leveled_direction = Vector3(vector.x,0,vector.z).normalized()
	var direction = vector.normalized()
	
	
	desired = desired.move_toward(direction,0.1)
	
	var leveled_desired = Vector3(desired.x,0,desired.z)
	
	rotation_degrees.y = -rad_to_deg(leveled_desired.signed_angle_to(Vector3.FORWARD,Vector3.UP))
	
	velocity = desired * SPEED
	
	
	
	
	
	move_and_slide()
	
	
	var bodies = $Area3D.get_overlapping_bodies()
	
	for b in bodies:
		if b.is_in_group("player"):
			b.get_hit(1)



func chase():
	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player")
		return
	
	
	var vector = target.global_position - self.global_position
	
	var direction = Vector3(vector.x,0,vector.z).normalized()
	
	desired = desired.move_toward(direction,0.1)
	
	rotation_degrees.y = -rad_to_deg(desired.signed_angle_to(Vector3.FORWARD,Vector3.UP))
	
	velocity = desired * SPEED
	
	
	
	
	
	move_and_slide()

func get_hit(damage: int = 1):
	$Ragdoll/Skeleton3D/PhysicalBoneSimulator3D.physical_bones_start_simulation()
	
	await get_tree().physics_frame
	$Visual.queue_free()
	$Ragdoll.show()
	
	await get_tree().create_timer(10).timeout
	
	queue_free()


func _on_timer_timeout():
	if boolean:
		boolean = false
	else:
		boolean = true
