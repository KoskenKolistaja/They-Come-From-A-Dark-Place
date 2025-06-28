extends CharacterBody3D


@export var player_id: int

@export var r_starting_weapon: PackedScene
@export var l_starting_weapon: PackedScene

@onready var skeleton_ik = $Visual/Suitman/Armature/Skeleton3D/SkeletonIK3D
@onready var skeleton_ik2 = $Visual/Suitman/Armature/Skeleton3D/SkeletonIK3D2



const JUMP_STRENGTH = 4
const SPEED = 1.75
#const SPEED = 10


var animation_vector = Vector2.ZERO

var flashlight_on = false

var bullets = 20000
var rockets = 1
var money = 500

var hp = 100

func _physics_process(delta):
	handle_movement()
	handle_actions()
	move_camera()


func _ready():
	
	
	if r_starting_weapon:
		var weapon_instance = r_starting_weapon.instantiate()
		add_right_hand_weapon(weapon_instance)
		$Visual/Suitman/Armature/Skeleton3D/SkeletonIK3D.start()
	if l_starting_weapon:
		var weapon_instance = l_starting_weapon.instantiate()
		add_left_hand_weapon(weapon_instance)
		$Visual/Suitman/Armature/Skeleton3D/SkeletonIK3D2.start()
	
	await get_tree().physics_frame
	
	update_hud_ammo()
	update_hud_money()
	update_hud_health()





func add_money(amount):
	money += amount

func update_hud_money():
	var hud = get_tree().get_first_node_in_group("hud")
	hud.update_money(player_id,money)

func update_hud_ammo():
	var hud = get_tree().get_first_node_in_group("hud")
	
	var ammo_numbers = {
		"bullets": bullets,
		"rockets": rockets
	}
	
	
	hud.update_ammo(player_id,ammo_numbers)

func update_hud_health():
	var hud = get_tree().get_first_node_in_group("hud")
	hud.update_health(player_id,hp)



func add_right_hand_weapon(weapon_instance):
	$Visual/Pivot/HandItem.add_child(weapon_instance)
	weapon_instance.player = self
	set_ik_target()

func add_left_hand_weapon(weapon_instance):
	$Visual/Pivot2/HandItem.add_child(weapon_instance)
	weapon_instance.player = self
	weapon_instance.left = true
	set_ik2_target()

func set_ik_target():
	var hand_item = $Visual/Pivot/HandItem.get_child(0)
	var handle = hand_item.get_node("Handle")
	$Visual/Suitman/Armature/Skeleton3D/SkeletonIK3D.set_target_node(handle.get_path())
	$Visual/Suitman/Armature/Skeleton3D/SkeletonIK3D.start()

func set_ik2_target():
	var hand_item = $Visual/Pivot2/HandItem.get_child(0)
	var handle = hand_item.get_node("Handle")
	$Visual/Suitman/Armature/Skeleton3D/SkeletonIK3D2.set_target_node(handle.get_path())
	$Visual/Suitman/Armature/Skeleton3D/SkeletonIK3D2.start()

func get_hit(damage: int = 1):
	hp -= damage
	
	$AudioStreamPlayer3D.play()
	$AnimationPlayer.play("Hurt")
	
	update_hud_health()
	
	if hp <= 0:
		if $Visual/Pivot/HandItem.get_child(0):
			drop_r_weapon()
		if $Visual/Pivot2/HandItem.get_child(0):
			drop_l_weapon()
		queue_free()

func handle_actions():
	
	if Input.is_action_pressed("p%d_action_right" % player_id):
		var hand_items = $Visual/Pivot/HandItem.get_children()
		if hand_items:
			for item in hand_items:
				
				item.action()
	
	if Input.is_action_pressed("p%d_action_left" % player_id):
		var hand_items = $Visual/Pivot2/HandItem.get_children()
		if hand_items:
			for item in hand_items:
				item.action()
	
	
	if Input.is_action_just_pressed("p%d_pickup_right" % player_id):
		if $Visual/Pivot/HandItem.get_child(0):
			drop_r_weapon()
		else:
			pickup_r_weapon()
	
	if Input.is_action_just_pressed("p%d_pickup_left" % player_id):
		if $Visual/Pivot2/HandItem.get_child(0):
			drop_l_weapon()
		else:
			pickup_l_weapon()
	
	#if Input.is_action_just_pressed("p1_reload_right"):
		#var hand_item = $Visual/Pivot/HandItem.get_child(0)
		#if hand_item:
			#if hand_item.has_method("reload"):
				#hand_item.reload()
	#if Input.is_action_just_pressed("p1_reload_left"):
		#var hand_item = $Visual/Pivot2/HandItem.get_child(0)
		#if hand_item:
			#if hand_item.has_method("reload"):
				#hand_item.reload()


#func toggle_flashlight():
	#
	#if not flashlight_on:
		#var tween = create_tween()
		#tween.tween_method(set_ik2_influence, 0.0, 0.82,0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		#flashlight_on = true
		#$Visual/Suitman/Armature/Skeleton3D/BoneAttachment3D/Flashlight.show()
	#else:
		#var tween = create_tween()
		#tween.tween_method(set_ik2_influence, 0.82, 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		#flashlight_on = false
		#$Visual/Suitman/Armature/Skeleton3D/BoneAttachment3D/Flashlight.hide()



func pickup_r_weapon():
	var items = $Area3D.get_overlapping_bodies()
	
	
	if not items:
		return
	else:
		var item = items[0]
		var weapon_instance = item.hand_item.instantiate()
		
		#if "ammo" in item:
			#weapon_instance.ammo = item.ammo
		
		add_right_hand_weapon(weapon_instance)
		item.queue_free()
		var tween = create_tween()
		tween.tween_method(set_ik_influence, 0.0, 1.0, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		set_ik_target()

func drop_r_weapon():
	
	var hand_item = $Visual/Pivot/HandItem.get_child(0)
	var type = hand_item.type
	
	#var ammo = null
	#
	#if "ammo" in hand_item:
		#ammo = hand_item.ammo
	
	var weapon = MetaData.weapons[type]
	
	var weapon_instance = weapon.instantiate()
	weapon_instance.global_transform = $Visual/Pivot/HandItem.global_transform
	
	#if ammo != null:
		#weapon_instance.ammo = ammo
	
	
	get_tree().current_scene.add_child(weapon_instance)
	
	clear_right_hand()

	#$Visual/Suitman/Armature/Skeleton3D/SkeletonIK3D.stop()

func pickup_l_weapon():
	var items = $Area3D.get_overlapping_bodies()
	
	if not items:
		return
	else:
		var item = items[0]
		var weapon_instance = item.hand_item.instantiate()
		
		#if "ammo" in item:
			#weapon_instance.ammo = item.ammo
		
		add_left_hand_weapon(weapon_instance)
		item.queue_free()
		var tween = create_tween()
		tween.tween_method(set_ik2_influence, 0.0, 1.0, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		set_ik2_target()

func drop_l_weapon():
	
	var hand_item = $Visual/Pivot2/HandItem.get_child(0)
	var type = hand_item.type
	
	#var ammo = null
	
	#if "ammo" in hand_item:
		#ammo = hand_item.ammo
	
	var weapon = MetaData.weapons[type]
	
	var weapon_instance = weapon.instantiate()
	weapon_instance.global_transform = $Visual/Pivot2/HandItem.global_transform
	
	#if ammo != null:
		#weapon_instance.ammo = ammo
	
	
	get_tree().current_scene.add_child(weapon_instance)
	
	clear_left_hand()


func set_ik_influence(value: float) -> void:
	skeleton_ik.set_influence(value)

func set_ik2_influence(value: float) -> void:
	skeleton_ik2.set_influence(value)

func clear_right_hand():
	var items = $Visual/Pivot/HandItem.get_children()
	for i in items:
		i.queue_free()
	var tween = create_tween()
	tween.tween_method(set_ik_influence, 1.0, 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func clear_left_hand():
	var items = $Visual/Pivot2/HandItem.get_children()
	for i in items:
		i.queue_free()
	var tween = create_tween()
	tween.tween_method(set_ik2_influence, 1.0, 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func handle_movement():
	
	
	
	var x = Input.get_joy_axis(player_id-1,JOY_AXIS_LEFT_X)
	var y = Input.get_joy_axis(player_id-1,JOY_AXIS_LEFT_Y)
	
	var vector2 = Vector2(x,y)
	
	var vector = Vector3(x,0,y)
	
	vector = vector.rotated(Vector3.UP,deg_to_rad(45))
	
	
	if vector.length() > 0.1:
		velocity.x = (vector * SPEED).x
		velocity.z = (vector * SPEED).z
	else:
		velocity.x = 0
		velocity.z = 0
	
	var rx = Input.get_joy_axis(player_id-1,JOY_AXIS_RIGHT_X)
	var ry = Input.get_joy_axis(player_id-1,JOY_AXIS_RIGHT_Y)
	
	if abs(rx) > 0.2:
		$Visual.rotation_degrees.y += -rx * 2
	if abs(ry) > 0.2:
		if ry > 0:
			if not $Visual/Pivot.rotation_degrees.x < -52:
				$Visual/Pivot.rotation_degrees.x += -ry * 1.5
				$Visual/Pivot2.rotation_degrees.x += -ry * 1.5
		else:
			if not $Visual/Pivot.rotation_degrees.x > 80:
				$Visual/Pivot.rotation_degrees.x += -ry * 1.5
				$Visual/Pivot2.rotation_degrees.x += -ry * 1.5
			pass
	
	var desired_animation_vector:Vector2 = Vector2(x,-y)
	
	if desired_animation_vector.length() > 0.1:
		animation_vector = animation_vector.move_toward(desired_animation_vector,0.1)
	else:
		animation_vector = animation_vector.move_toward(Vector2.ZERO,0.1)
	
	
	var angle = $Visual.global_transform.basis.z.normalized().signed_angle_to(Vector3(-1,0,-1),Vector3.UP)
	
	print(angle)
	
	var end_vector = -animation_vector.rotated(angle)
	
	$Visual/Suitman/AnimationTree.set("parameters/Walk/blend_position", end_vector)
	
	if is_on_floor():
		if Input.is_action_just_pressed("p%d_jump" % player_id):
			velocity.y += 1 * JUMP_STRENGTH
	else:
		velocity.y -= 0.2
	
	move_and_slide()



func move_camera():
	var desired = self.global_position + Vector3(0,4,4)
	var current_position: Vector3 = $Camera3D.global_position
	var ratio = (desired - current_position).length()
	
	$Camera3D.global_position = current_position.move_toward(desired,ratio/10)
