extends OmniLight3D


@export var flicker_speed := 0.12
@export var min_energy := 0.8
@export var max_energy := 1.2

func _ready():
	randomize()

func _process(delta):
	if randf() < flicker_speed:
		light_energy = randf_range(min_energy, max_energy)
