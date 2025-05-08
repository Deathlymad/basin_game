extends Node3D

var hexagons : Array[Hexagon]
@export var size : int
@export var direction : HexHelper.HexDirection

func _ready():
	hexagons = []
	var start_pos = HexHelper.HexCoordinate.new(0, 0, 0)
	var next_dir = HexHelper.get_next_hex_direction(direction)
	start_pos = start_pos.step_in_dir(direction)
	var root = start_pos.duplicate()
	
	print("==============================", direction, " ", next_dir, "==============================")
	
	for i in range(size):
		var hex = Hexagon.new()
		hex.hex_position = start_pos.duplicate().minus(root)
		hex.grid_radius = size
		print(hex.hex_position)
		hexagons.append(hex)
		var step_pos = start_pos.duplicate()
		start_pos.step_in_dir(direction)
		step_pos.step_in_dir(next_dir)
		for j in range(size - i - 1):
			hex = Hexagon.new()
			hex.hex_position = step_pos.duplicate().minus(root)
			hex.grid_radius = size
			print(hex.hex_position)
			hexagons.append(hex)
			step_pos.step_in_dir(next_dir)
	
	print("============================================================")
	generate_mesh()
	global_position = root.to_carthesian()

func add_hexagons_to_geometry(arrays):
	for hex in hexagons:
		var res = hex._update_mesh(to_local(hex.hex_position.to_carthesian()), arrays[Mesh.ARRAY_VERTEX].size())
		arrays[Mesh.ARRAY_VERTEX].append_array(res[0])
		arrays[Mesh.ARRAY_INDEX].append_array(res[1])
		arrays[Mesh.ARRAY_TEX_UV].append_array(res[2])
	

func add_connectors_to_grid():
	pass

func generate_mesh():
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array()
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array()
	
	add_hexagons_to_geometry(arrays)
	
	# Create the Mesh.
	$MeshInstance3D.mesh = ArrayMesh.new()
	$MeshInstance3D.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	for c in $MeshInstance3D.get_children():
		$MeshInstance3D.remove_child(c)
	$MeshInstance3D.create_multiple_convex_collisions()
