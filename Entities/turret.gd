extends Node3D

var target

var rotation_speed = 1

var left_loaded = true
var right_loaded = false

@export var tracer: PackedScene
@export var strike: PackedScene
@export var decal: PackedScene





func _physics_process(delta):
	
	
	if target:
		rotate_towards_target()
		
		if $Cube/HPivot/TargetRay.is_colliding():
			if $Cube/HPivot/TargetRay.get_collider() == target:
				shoot()




func rotate_towards_target():
	var vector = target.global_position - self.global_position
	var h_vector = Vector3(vector.x,0,vector.z)
	
	var angle = rad_to_deg(h_vector.signed_angle_to(Vector3.FORWARD,Vector3.DOWN))
	
	
	
	$Cube/HPivot.rotation_degrees.y = move_toward($Cube/HPivot.rotation_degrees.y,angle,rotation_speed)



func _on_target_timer_timeout():
	update_target()



func update_target():
	var list = $Area3D.get_overlapping_bodies()
	var closest = null
	
	if list:
		closest = get_closest_from(list)
	
	target = closest



func get_closest_from(list: Array):
	var closest = list[0]
	var closest_distance = (closest.global_position - self.global_position).length()
	
	for i in list:
		var i_distance = (i.global_position - self.global_position).length()
		if i_distance < closest_distance:
			i = closest
	
	return closest


func shoot():
	
	if left_loaded:
		check_for_hit($Cube/HPivot/VPivot/PipeL/RayCast3D2,$Cube/HPivot/VPivot/PipeL/L_End_point.global_position)
		$LPlayer.play("shoot")
		left_loaded = false
		$RTimer.start()
	elif right_loaded:
		check_for_hit($Cube/HPivot/VPivot/PipeR/RayCast3D,$Cube/HPivot/VPivot/PipeR/R_End_point.global_position)
		$RPlayer.play("shoot")
		right_loaded = false
		$LTimer.start()


func spawn_trace(ray,collision_point,end_point):
	var ray_start = ray.global_position
	var ray_end = end_point
	var direction = (ray_end - ray_start).normalized()
	var tracer_instance = tracer.instantiate()
	if collision_point:
		tracer_instance.end_point = collision_point
	tracer_instance.direction = direction
	tracer_instance.global_transform = ray.global_transform
	tracer_instance.scale = Vector3(1,1,1)
	tracer_instance.look_at_from_position(ray.global_position,ray.global_position + direction)
	get_tree().current_scene.add_child(tracer_instance)

func spawn_strike(spawn_position):
	var strike_instance = strike.instantiate()
	get_tree().current_scene.add_child(strike_instance)
	strike_instance.global_position = spawn_position

func spawn_decal(spawn_position, parent, normal):
	var decal_instance: Node3D = decal.instantiate()
	var child_transform = decal_instance.global_transform
	parent.add_child(decal_instance,true)
	decal_instance.global_transform = child_transform
	decal_instance.global_position = spawn_position
	decal_instance.look_at_from_position(decal_instance.global_position,(decal_instance.global_position + normal*50))




func check_for_hit(ray,end_point):
	
	var collider = ray.get_collider()
	var collision_point = ray.get_collision_point()
	var normal = ray.get_collision_normal()
	spawn_trace(ray,collision_point,end_point)
	
	if not collider:
		return
	else:
		spawn_strike(collision_point)
		spawn_decal(collision_point, collider,normal)
		
		if collider.has_method("get_hit"):
			
			
			
			if collider.has_method("store_impact"):
				var dic = {}
				
				var start_point = ray.global_position
				
				dic = {"start_point" : start_point , "end_point" : end_point , "strength" : 10, "killer": null}
				
				
				collider.store_impact(dic)
			
			collider.get_hit()
		elif collider.has_method("apply_impulse"):
			var vector = (collision_point - self.global_position).normalized() * 10
			collider.apply_impulse(vector, collision_point,)





func _on_l_timer_timeout():
	left_loaded = true


func _on_r_timer_timeout():
	right_loaded = true
