extends CharacterBody3D


const SPEED = 3.0
const JUMP_VELOCITY = 4.5

@export var corpse: PackedScene

@export var death_sounds: AudioStream
@export var idle_sounds: AudioStream
@export var hit_mark: AudioStream

@onready var state_machine = $zombie/AnimationTree.get("parameters/playback")

var dead = false

var desired = Vector3.FORWARD

var target

var killer

var award_money: int = 10

var impact: Dictionary

var bone_name_map = {
	"mixamorig_Hips": "spine",
	"mixamorig_Head": "spine_004",
	"mixamorig_Spine2": "spine_002",
	"mixamorig_LeftShoulder": "upper_arm_L",
	"mixamorig_LeftForeArm": "forearm_L",
	"mixamorig_RightShoulder": "upper_arm_R",
	"mixamorig_RightForeArm": "forearm_R"
}


enum STATE {
	IDLE,
	CHASING,
	HITTING,
	DEAD
}

var hp = 1

var state = STATE.IDLE

var color


func _ready():
	$AudioTimer.wait_time = randf_range(2,15)
	$AudioTimer.start()
	
	
	$TargetTimer.wait_time = randf_range(0.5,1)
	
	target = get_tree().get_first_node_in_group("player")
	state_machine.travel("running")
	
	set_color()

func set_killer(object):
	killer = object

func set_color():
	var mesh: MeshInstance3D = $"zombie/Armature/Skeleton3D/Character rough_004"
	var mat: StandardMaterial3D = mesh.get_surface_override_material(0)
	
	var rand_color = Color(randf(),randf(),randf())
	var org_color = Color(0.351, 0.467, 0.405)
	
	var mixed_color = org_color.lerp(rand_color,0.2)
	
	color = mixed_color
	mat.albedo_color = mixed_color


func _physics_process(delta):
	match state:
		STATE.IDLE:
			idle()
		STATE.CHASING:
			chase()
		STATE.HITTING:
			hitting()
		STATE.DEAD:
			pass
	







func idle():
	state_machine.travel("idle")
	
	if target:
		change_state(STATE.CHASING)


func check_for_hit():
	var bodies = $Area3D.get_overlapping_bodies()
	
	for item in bodies:
		if item.has_method("get_hit"):
			item.get_hit(10)


func hitting():
	var current_state = state_machine.get_current_node()
	
	if current_state != "punch":
		change_state(STATE.IDLE)
	
	if target:
		var vector = target.global_position - self.global_position
		
		var direction = Vector3(vector.x,0,vector.z).normalized()
		
		desired = desired.move_toward(direction,0.1)
		
		rotation_degrees.y = -rad_to_deg(desired.signed_angle_to(Vector3.FORWARD,Vector3.UP))

func change_state(new_state):
	state = new_state


func chase():
	state_machine.travel("running")
	if not is_instance_valid(target):
		target = get_tree().get_first_node_in_group("player")
		return
	
	if not target:
		change_state(STATE.IDLE)
	
	var vector = target.global_position - self.global_position
	
	var direction = Vector3(vector.x,0,vector.z).normalized()
	
	desired = desired.move_toward(direction,0.1)
	
	rotation_degrees.y = -rad_to_deg(desired.signed_angle_to(Vector3.FORWARD,Vector3.UP))
	
	velocity = desired * SPEED
	
	if not $RayCast3D.is_colliding():
		velocity.y -= 1
	else:
		velocity.y = 0
	
	
	
	var bodies = $Area3D.get_overlapping_bodies()
	
	for b in bodies:
		if b.is_in_group("player"):
			change_state(STATE.HITTING)
			state_machine.travel("punch")

	
	move_and_slide()


func update_target():
	target = get_closest_player()
	if not target or not is_instance_valid(target):
		target = null
		return

func get_closest_player():
	var players = get_tree().get_nodes_in_group("player")
	var closest
	
	if players:
		closest = players[0]
	else:
		return
	
	for p in players:
		var closest_distance = (closest.global_position - self.global_position).length()
		var current_distance = (p.global_position - self.global_position).length()
		if current_distance < closest_distance:
			closest = p
	
	return closest


func store_impact(exported_impact):
	impact = exported_impact
	if exported_impact["killer"]:
		killer = exported_impact["killer"]

func get_hit(damage: int = 1):
	Audio.assign_sound(hit_mark)
	hp -= damage
	
	if hp <= 0:
		die()

func delete():
	var r_number = randf_range(0,5)
	change_state(STATE.DEAD)
	await get_tree().create_timer(r_number).timeout
	Audio.assign_sound(death_sounds,-20.0)
	spawn_ragdoll()





func die():
	Audio.assign_sound(death_sounds,-12.0)
	
	if killer:
		killer.add_money(award_money)
		killer.update_hud_money()
	change_state(STATE.DEAD)
	spawn_ragdoll()
	#$CollisionShape3D.disabled = true
	#var rand_int = randi_range(1,3)
	#
	#var death_anim = "death" + str(rand_int)
	#
	#state = STATE.DEAD
	#
	#state_machine.travel(death_anim)
	#dead = true
	#await get_tree().create_timer(20).timeout
	#queue_free()


func _on_area_3d_body_entered(body):
	pass # Replace with function body.


func _on_target_timer_timeout():
	update_target()


func spawn_ragdoll():
	
	
	var skeleton: Skeleton3D = $zombie/Armature/Skeleton3D
	var corpse_instance = $ZombieCorpse
	
	if not skeleton:
		return
	
	corpse_instance.global_transform = global_transform
	
	if impact:
		corpse_instance.impact = impact
		$ImpactArea.global_position = impact["collision_point"]
	
	get_tree().current_scene.add_child(corpse_instance)
	corpse_instance.set_color(color)
	
	
	var corpse_skeleton: Skeleton3D = corpse_instance.get_node("metarig/Skeleton3D")
	transfer_named_bones(skeleton, corpse_skeleton,bone_name_map)
	
	
	corpse_skeleton.physical_bones_start_simulation()
	
	
	transfer_named_bones(skeleton, corpse_skeleton,bone_name_map)
	
	$CollisionShape3D.disabled = true
	
	await get_tree().physics_frame
	
	apply_impact_to_bones()
	
	$ZombieCorpse.show()
	$zombie.queue_free()
	
	await get_tree().create_timer(50).timeout
	
	
	queue_free()


func apply_impact_to_bones():
	var bones = $ImpactArea.get_overlapping_bodies()
	print(bones)
	
	for bone in bones:
		var impulse_vector = impact["direction"] * impact["strength"]
		var point = impact["collision_point"]
		
		bone.apply_impulse(impulse_vector,point)

func transfer_named_bones(animated_skeleton: Skeleton3D, corpse_skeleton: Skeleton3D, bone_map: Dictionary) -> void:
	for anim_bone_name in bone_map.keys():
		var ragdoll_node_name = bone_map[anim_bone_name]

		var anim_bone_index = animated_skeleton.find_bone(anim_bone_name)
		if anim_bone_index == -1:
			push_warning("Missing animated bone: " + anim_bone_name)
			continue

		var anim_pose = animated_skeleton.global_transform * animated_skeleton.get_bone_global_pose_no_override(anim_bone_index)

		var phys_bone_node: Node = corpse_skeleton.get_node_or_null(ragdoll_node_name)
		if phys_bone_node and phys_bone_node is PhysicalBone3D:
			phys_bone_node.global_transform = anim_pose
			phys_bone_node.scale = Vector3(1,1,1)
		else:
			push_warning("Missing or invalid ragdoll bone node: " + ragdoll_node_name)


func _on_audio_timer_timeout():
	
	$AudioStreamPlayer3D.stream = idle_sounds
	$AudioStreamPlayer3D.play()
	
	$AudioTimer.wait_time = randi_range(2,15)
	$AudioTimer.start()
