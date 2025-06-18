extends Node3D



var loaded = true

var type = "revolver"


var player

var left = false

@export var tracer: PackedScene
@export var strike: PackedScene
@export var decal: PackedScene

func action():
	if loaded and player.bullets > 0:
		$AnimationPlayer.play("shoot")
		$AudioStreamPlayer.play()
		$Handle/GPUParticles3D.emitting = true
		loaded = false
		$Timer.start()
		check_for_hit()
		spawn_trace()
		player.bullets -= 1
		player.update_hud_ammo()

func spawn_trace():
	var direction = $Handle/Cube/RayCast3D.global_transform.basis.z.normalized() * -1
	var tracer_instance = tracer.instantiate()
	tracer_instance.direction = direction.normalized()
	tracer_instance.global_transform = $Handle/Cube/RayCast3D.global_transform
	tracer_instance.scale = Vector3(2,2,2)
	get_tree().current_scene.add_child(tracer_instance)

func spawn_strike(spawn_position):
	var strike_instance = strike.instantiate()
	strike_instance.global_position = spawn_position
	get_tree().current_scene.add_child(strike_instance)

func spawn_decal(spawn_position, parent, normal):
	var decal_instance: Node3D = decal.instantiate()
	var child_transform = decal_instance.global_transform
	parent.add_child(decal_instance,true)
	decal_instance.global_transform = child_transform
	decal_instance.global_position = spawn_position
	decal_instance.look_at_from_position(decal_instance.global_position,(decal_instance.global_position + normal*50))


func check_for_hit():
	var ray: RayCast3D = $Handle/Cube/RayCast3D
	var collider = ray.get_collider()
	var collision_point = ray.get_collision_point()
	var normal = ray.get_collision_normal()
	
	if not collider:
		return
	else:
		spawn_strike($Handle/Cube/RayCast3D.get_collision_point())
		if collider.has_method("get_hit"):
			
			spawn_decal(collision_point, collider,normal)
			
			
			if collider.has_method("store_impact"):
				var dic = {}
				
				var start_point = ray.global_position
				var end_point = $Handle/Cube/EndPoint.global_position
				
				dic = {"start_point" : start_point , "end_point" : end_point , "strength" : 10, "killer": player}
				
				
				collider.store_impact(dic)
				
			
			collider.get_hit()


func _on_timer_timeout():
	loaded = true
