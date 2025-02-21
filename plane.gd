extends StaticBody3D
@export var mesh : MeshInstance3D

func get_mesh():
	return mesh.get_active_material(0)
