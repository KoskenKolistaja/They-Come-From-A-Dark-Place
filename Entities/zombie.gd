extends CharacterBody3D

const SPEED = 3.0
@export var corpse: PackedScene
@export var death_sounds: AudioStream
@export var idle_sounds: AudioStream
@export var hit_mark: AudioStream
@onready var state_machine = $zombie/AnimationTree.get("parameters/playback")
var dead = false
var desired = Vector3.FORWARD
var target
var killer
var award_money = 10
var impact: Dictionary = {}
var hp = 1
var color: Color

enum STATE { IDLE, CHASING, HITTING, DEAD }
var state = STATE.IDLE
var bone_name_map = {
	"spine": "mixamorig_Hips",
	"spine.001": "mixamorig_Spine",
	"spine.002": "mixamorig_Spine1",
	"spine.003": "mixamorig_Spine2",
	"spine.004": "mixamorig_Neck",
	"spine.005": "mixamorig_Head",
	"spine.006": "mixamorig_HeadTop_End",
	"upper_arm.L": "mixamorig_LeftArm",
	"forearm.L": "mixamorig_LeftForeArm",
	"hand.L": "mixamorig_LeftHand",
	"upper_arm.R": "mixamorig_RightArm",
	"forearm.R": "mixamorig_RightForeArm",
	"hand.R": "mixamorig_RightHand",
	"thigh.L": "mixamorig_LeftUpLeg",
	"shin.L": "mixamorig_LeftLeg",
	"foot.L": "mixamorig_LeftFoot",
	"toe.L": "mixamorig_LeftToeBase",
	"thigh.R": "mixamorig_RightUpLeg",
	"shin.R": "mixamorig_RightLeg",
	"foot.R": "mixamorig_RightFoot",
	"toe.R": "mixamorig_RightToeBase"
}

func _ready():
	$AudioTimer.start(randf_range(2, 15))
	$TargetTimer.start(randf_range(0.5, 1.0))
	update_target()
	var mesh = $"zombie/Armature/Skeleton3D/Character rough_004"
	var mat = mesh.get_surface_override_material(0).duplicate()
	mesh.set_surface_override_material(0, mat)
	color = Color(0.351, 0.467, 0.405).lerp(Color(randf(), randf(), randf()), 0.2)
	mat.albedo_color = color

func _physics_process(delta):
	if dead:
		return
	if not is_instance_valid(target) or not target.is_in_group("player"):
		update_target()
	if not is_instance_valid(target):
		return
	var vector = target.global_position - global_position
	var direction = Vector3(vector.x, 0, vector.z).normalized()
	desired = desired.move_toward(direction, 6.0 * delta)
	rotation.y = -desired.signed_angle_to(Vector3.FORWARD, Vector3.UP)
	match state:
		STATE.HITTING:
			if state_machine.get_current_node() != "punch":
				state = STATE.IDLE
		_:
			if state != STATE.CHASING:
				state_machine.travel("running")
				state = STATE.CHASING
			velocity.x = desired.x * SPEED
			velocity.z = desired.z * SPEED
			if not is_on_floor():
				velocity += get_gravity() * delta
			else:
				velocity.y = 0.0
			move_and_slide()
			for body in $Area3D.get_overlapping_bodies():
				if body.is_in_group("player"):
					state = STATE.HITTING
					state_machine.travel("punch")
					break

func check_for_hit():
	if dead:
		return
	for body in $Area3D.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.get_hit(10)

func update_target():
	target = null
	var closest_distance = INF
	for player in get_tree().get_nodes_in_group("player"):
		var distance = global_position.distance_squared_to(player.global_position)
		if distance < closest_distance:
			closest_distance = distance
			target = player

func set_killer(object):
	killer = object

func store_impact(data):
	if not dead:
		impact = data
		killer = data.get("killer")

func get_hit(damage: int = 1):
	if dead:
		return
	Audio.assign_sound(hit_mark)
	hp -= damage
	if hp <= 0:
		die()

func die():
	if dead:
		return
	dead = true
	state = STATE.DEAD
	$zombie/AnimationTree.active = false
	remove_from_group("enemy")
	set_physics_process(false)
	$CollisionShape3D.set_deferred("disabled", true)
	$AudioTimer.stop()
	$TargetTimer.stop()
	$ScreenTimeTimer.stop()
	Audio.assign_sound(death_sounds, -12.0)
	if is_instance_valid(killer):
		killer.add_money(award_money)
		killer.update_hud_money()
	call_deferred("spawn_ragdoll")

func delete():
	# Wave cleanup does not award money or build dozens of new ragdolls.
	if dead:
		return
	dead = true
	remove_from_group("enemy")
	queue_free()

func spawn_ragdoll():
	if MetaData.max_ragdolls <= 0 or corpse == null:
		queue_free()
		return
	var ragdoll = corpse.instantiate()
	ragdoll.transform = transform
	get_parent().add_child(ragdoll)
	var skeleton: Skeleton3D = $zombie/Armature/Skeleton3D
	ragdoll.copy_pose_from(skeleton, bone_name_map)
	$zombie.hide()
	ragdoll.activate(impact, color)
	queue_free()

func _on_area_3d_body_entered(_body):
	pass

func _on_target_timer_timeout():
	if not dead:
		update_target()

func _on_audio_timer_timeout():
	if dead:
		return
	$AudioStreamPlayer3D.stream = idle_sounds
	$AudioStreamPlayer3D.play()
	$AudioTimer.start(randf_range(2, 15))

func _on_screen_time_timer_timeout():
	if not dead and not $ScreenNotifier.is_on_screen():
		var spawner = get_tree().get_first_node_in_group("enemy_spawner")
		if is_instance_valid(spawner):
			spawner.reserve_zombie()
		delete()
