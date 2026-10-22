extends CharacterBody3D

var target
var desired = Vector3.FORWARD
var hp = 20
var attack_cooldown = 0.0
@onready var animation = $"Heavytaur Rigged with root/AnimationPlayer"

func _ready():
	animation.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS

func _physics_process(delta):
	if not is_instance_valid(target) or not target.is_in_group("player"):
		target = get_tree().get_first_node_in_group("player")
	if not is_instance_valid(target):
		return
	var offset = target.global_position - global_position
	var direction = Vector3(offset.x, 0, offset.z).normalized()
	desired = desired.move_toward(direction, 6.0 * delta)
	rotation.y = -desired.signed_angle_to(Vector3.FORWARD, Vector3.UP)
	var root_velocity = -(global_basis * animation.get_root_motion_position()) / delta
	velocity.x = root_velocity.x
	velocity.z = root_velocity.z
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	if offset.length_squared() < 4.0 and attack_cooldown <= 0.0:
		target.get_hit(20)
		attack_cooldown = 1.5

func get_hit(damage: int = 1):
	if is_queued_for_deletion():
		return
	hp -= damage
	if hp <= 0:
		delete()

func delete():
	remove_from_group("enemy")
	queue_free()
