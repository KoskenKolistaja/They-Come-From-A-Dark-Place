extends Node3D



func _ready():
	$SubViewport.debug_draw = 2
	#$SubViewport/MeshInstance3D.global_position = self.global_position
	$SubViewport/MeshInstance3D.global_transform.origin = get_parent().global_position



#func _physics_process(delta):
	#$SubViewport/MeshInstance3D/Label3D.text = "Light Level: " + str(snapped(get_light_level(),0.01))


func get_light_level():
	
	rerender_subviewport_once($SubViewport)
	
	var viewport_texture = $SubViewport.get_viewport().get_texture()
	var color = get_average_color(viewport_texture)
	var light_level: float = color.get_luminance()
	
	return light_level


func rerender_subviewport_once(subviewport: SubViewport):
	subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	await get_tree().process_frame
	subviewport.render_target_update_mode = SubViewport.UPDATE_ONCE


func get_average_color(texture: ViewportTexture) -> Color:
	var image = texture.get_image()
	image.resize(1,1,Image.INTERPOLATE_LANCZOS)
	return image.get_pixel(0,0)
