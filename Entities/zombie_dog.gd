extends CharacterBody3D


var target

var desired = Vector3.ZERO

const SPEED = 6.0

var boolean = false

var dead = false

@onready var state_machine = $zombiedog2/AnimationTree.get("parameters/playback")



func _ready():
	target = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if target and not dead:
		var distance = (target.global_position - self.global_position).length()
		
		if distance < 5:
			jump()
			state_machine.travel("Attack3")
		else:
			chase()
	elif not dead:
		move_and_slide()

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
			get_hit()



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
	$zombiedog/metarig/Skeleton3D/PhysicalBoneSimulator3D.physical_bones_start_simulation()
	
	await get_tree().physics_frame
	dead = true
	$CollisionShape3D.queue_free()
	$zombiedog2.queue_free()
	$zombiedog.show()
	
	await get_tree().create_timer(10).timeout
	
	queue_free()


func _on_timer_timeout():
	if boolean:
		boolean = false
	else:
		boolean = true
