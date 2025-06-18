extends Node3D


var loaded = true

var type = "uzi"
var ammo_type = "bullet"

#const MAX_AMMO : int = 20
#
#var ammo : int = 20
#
#var overall_ammo : int = 100

@export var tracer: PackedScene
@export var strike: PackedScene
@export var decal: PackedScene

@export var shoot_sound: AudioStream

var player
var left = false

var reloading = false

#func _ready():
	#await  get_tree().physics_frame
	#update_hud_ammo()


func action():
	if loaded and player.bullets > 0:
		$AnimationPlayer.play("shoot")
		Audio.assign_sound(shoot_sound,-18.0)
		$Handle/GPUParticles3D.emitting = true
		loaded = false
		$Timer.start()
		check_for_hit()
		$Handle/Cube/RayCast3D.target_position.x = randf_range(-1,1)
		$Handle/Cube/RayCast3D.target_position.y = randf_range(-1,1)
		#update_hud_ammo()
		player.bullets -= 1
		player.update_hud_ammo()

func spawn_trace(collision_point):
	var ray_start = $Handle/Cube/RayCast3D.global_position
	var ray_end = to_global($Handle/Cube/RayCast3D.get_target_position())
	var direction = (ray_end - ray_start).normalized()
	var tracer_instance = tracer.instantiate()
	if collision_point:
		tracer_instance.end_point = collision_point
	tracer_instance.direction = direction
	tracer_instance.global_transform = $Handle/Cube/RayCast3D.global_transform
	tracer_instance.look_at_from_position($Handle/Cube/RayCast3D.global_position,$Handle/Cube/RayCast3D.global_position + direction)
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




func check_for_hit():
	var ray: RayCast3D = $Handle/Cube/RayCast3D
	var collider = $Handle/Cube/RayCast3D.get_collider()
	var collision_point =$Handle/Cube/RayCast3D.get_collision_point()
	var normal = $Handle/Cube/RayCast3D.get_collision_normal()
	spawn_trace(collision_point)
	
	if not collider:
		return
	else:
		spawn_strike(collision_point)
		spawn_decal(collision_point, collider,normal)
		
		if collider.has_method("get_hit"):
			
			
			
			if collider.has_method("store_impact"):
				var dic = {}
				
				var start_point = ray.global_position
				var end_point = $Handle/Cube/EndPoint.global_position
				
				dic = {"start_point" : start_point , "end_point" : end_point , "strength" : 10, "killer": player}
				
				
				collider.store_impact(dic)
			
			collider.get_hit()
		elif collider.has_method("apply_impulse"):
			var vector = (collision_point - self.global_position).normalized() * 10
			collider.apply_impulse(vector, collision_point,)



#func reload():
	#if ammo >= MAX_AMMO or overall_ammo == 0:
		#return
	#
	#reloading = true
	#
	#await get_tree().create_timer(1).timeout
	#var subtraction = MAX_AMMO - ammo
	#
	#if overall_ammo >= subtraction:
		#overall_ammo -= subtraction
		#ammo = MAX_AMMO
	#else:
		#ammo += overall_ammo
		#overall_ammo = 0
	#update_hud_ammo()
	#
	#reloading = false


#func update_hud_ammo():
	#
	#var hud = get_tree().get_first_node_in_group("hud")
	#
	#var ammo_info = {
		#"ammo" : ammo,
		#"overall_ammo" : overall_ammo,
		#"left" : left
		#}
	#
	#hud.update_ammo(player.player_id, ammo_info)

func _on_timer_timeout():
	loaded = true
