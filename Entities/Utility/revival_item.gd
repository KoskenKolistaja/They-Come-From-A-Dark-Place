extends CharacterBody3D


var revival = 0

@export var text: String


func _physics_process(delta):
	$ProgressBar.hide()
	revival = move_toward(revival,0,0.1)
	if revival > 100:
		revive()

func action(caller):
	#revival = move_toward(revival,101,0.2)
	#$ProgressBar.show()
	#$ProgressBar.value = revival
	revive()

func revive():
	get_parent().get_up()
	queue_free()
