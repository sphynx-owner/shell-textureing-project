@tool
extends MeshInstance3D

@export var plane_count : int = 10:
	set(value):
		plane_count = value 
		update_tessellation()

@export var height : float = 1:
	set(value):
		height = value
		update_tessellation()

var all_planes : Array[MeshInstance3D] 

func _ready() -> void:
	update_tessellation()

func _set(property: StringName, value: Variant) -> bool:
	if property == "surface_material_override/0":
		if get_surface_override_material(0):
			get_surface_override_material(0).changed.disconnect(update_tessellation)
		if value:
			(value as Material).changed.connect(update_tessellation)
	return false

func clear_planes():
	for plane in all_planes:
		plane.queue_free()
	
	all_planes.clear()

func update_tessellation():
	clear_planes()
	print("cleared planes")
	for i in plane_count:
		var new_plane : MeshInstance3D = MeshInstance3D.new()
		new_plane.mesh = mesh
		new_plane.set_surface_override_material(0, get_surface_override_material(0).duplicate())
		all_planes.append(new_plane)
		add_child(new_plane)
		new_plane.position.y = height / float(plane_count) * (i + 1)
		new_plane.get_surface_override_material(0).render_priority = i - 96
		new_plane.get_surface_override_material(0).set_shader_parameter("height", 1. / float(plane_count) * (float(i) + 1.))
