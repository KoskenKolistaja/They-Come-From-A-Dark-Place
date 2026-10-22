extends CharacterBody3D

var target
var desired = Vector3.ZERO
const SPEED = 6.0
var dead = false
@onready var state_machine = $zombiedog2/AnimationTree.get("parameters/playback")
const CORPSE = preload("res://Entities/zombie_dog_corpse.tscn")

func _ready():
	add_to_group("enemy")

func _physics_process(delta):
	if dead:
		return
	if not is_instance_valid(target) or not target.is_in_group("player"):
		target = get_tree().get_first_node_in_group("player")
	if not is_instance_valid(target):
		return
	var offset = target.global_position - global_position
	var attacking = offset.length_squared() < 25.0
	if attacking:
		offset += Vector3.UP
		if state_machine.get_current_node() != "Attack3":
			state_machine.travel("Attack3")
	var direction = offset.normalized() if attacking else Vector3(offset.x, 0, offset.z).normalized()
	desired = desired.move_toward(direction, 6.0 * delta)
	var flat = Vector3(desired.x, 0, desired.z)
	if not flat.is_zero_approx():
		rotation.y = -flat.signed_angle_to(Vector3.FORWARD, Vector3.UP)
	velocity = desired * SPEED
	if not attacking and not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	if attacking:
		for body in $Area3D.get_overlapping_bodies():
			if body.is_in_group("player"):
				body.get_hit(1)
				get_hit()
				break

func get_hit(_damage: int = 1):
	if dead:
		return
	dead = true
	remove_from_group("enemy")
	set_physics_process(false)
	$CollisionShape3D.set_deferred("disabled", true)
	call_deferred("spawn_corpse")

func spawn_corpse():
	if MetaData.max_ragdolls > 0:
		var corpse = CORPSE.instantiate()
		corpse.transform = transform * corpse.transform
		get_parent().add_child(corpse)
	queue_free()

func delete():
	dead = true
	remove_from_group("enemy")
	queue_free()

func _on_timer_timeout():
	pass
