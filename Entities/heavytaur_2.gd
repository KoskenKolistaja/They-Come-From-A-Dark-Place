extends CharacterBody3D


const SPEED = 1.5
const JUMP_VELOCITY = 4.5

var target

var desired = Vector3.FORWARD

var root_velocity

var hp = 20


func _ready():
	target = get_tree().get_first_node_in_group("player")


func _process(delta):
	var anim_player: AnimationPlayer =  $"Heavytaur Rigged with root/AnimationPlayer"
	var root_pos = anim_player.get_root_motion_position()
	var current_rotation = anim_player.get_root_motion_rotation_accumulator()
	root_velocity = global_transform.basis * (root_pos / delta)

func _physics_process(delta):
	if not target:
		return
	
	var vector = target.global_position - self.global_position
	
	var direction = Vector3(vector.x,0,vector.z).normalized()
	
	desired = desired.move_toward(direction,0.1)
	
	if root_velocity:
		velocity = -root_velocity
	
	
	rotation_degrees.y = -rad_to_deg(desired.signed_angle_to(Vector3.FORWARD,Vector3.UP))
	
	move_and_slide()


func get_hit(damage: int = 1):
	hp -= damage
	if hp <= 0:
		queue_free()
