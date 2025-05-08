extends Node3D

var hexagons : Array[Hexagon]
@export var size : int
@export var direction : HexHelper.HexDirection

var uv_ratio : Vector2

func _calculate_global_uv_ratio():
	
	var extremes : Array[Vector3]
	
	extremes.append(HexHelper.HexCoordinate.new(0,0,size).to_carthesian())
	extremes.append(HexHelper.HexCoordinate.new(size,0,0).to_carthesian())
	extremes.append(HexHelper.HexCoordinate.new(0,0,-size).to_carthesian())
	extremes.append(HexHelper.HexCoordinate.new(-size,0,0).to_carthesian())
	
	var min = Vector2.ZERO
	var max = Vector2.ZERO
	
	for pt in extremes:
		min.x = min(pt.x, min.x)
		min.y = min(pt.z, min.y)
		max.x = max(pt.x, max.y)
		max.y = max(pt.z, max.y)
	
	uv_ratio = max - min
	
func _ready():
	hexagons = []
	var start_pos = HexHelper.HexCoordinate.new(0, 0, 0)
	var next_dir = HexHelper.get_next_hex_direction(direction)
	start_pos = start_pos.step_in_dir(direction)
	var root = start_pos.duplicate()
	
	for i in range(size):
		var hex = Hexagon.new()
		hex.hex_position = start_pos.duplicate()
		hexagons.append(hex)
		var step_pos = start_pos.duplicate()
		start_pos.step_in_dir(direction)
		step_pos.step_in_dir(next_dir)
		for j in range(size - i - 1):
			hex = Hexagon.new()
			hex.hex_position = step_pos.duplicate()
			hexagons.append(hex)
			step_pos.step_in_dir(next_dir)
	
	generate_mesh()

func add_hexagons_to_geometry(arrays):
	for hex in hexagons:
		var res = hex._update_mesh(uv_ratio, Vector2(global_position.x, global_position.z), hex.hex_position.to_carthesian(), arrays[Mesh.ARRAY_VERTEX].size())
		arrays[Mesh.ARRAY_VERTEX].append_array(res[0])
		arrays[Mesh.ARRAY_INDEX].append_array(res[1])
		arrays[Mesh.ARRAY_TEX_UV].append_array(res[2])
	

func add_connectors_to_grid(arrays):
	var i = 0
	var last_in_major_dir = 0
	var next_dir = HexHelper.get_next_hex_direction(direction)
	for h in range(size):
		
		#pass
		
		i += 7
		for j in range(size - h - 2):
			
			i += 7
			arrays[Mesh.ARRAY_INDEX].append(i + direction)
			arrays[Mesh.ARRAY_INDEX].append(i + next_dir)
			arrays[Mesh.ARRAY_INDEX].append(i + 7 + HexHelper.get_opposite_hex_direction(direction))
			arrays[Mesh.ARRAY_INDEX].append(i + next_dir)
			arrays[Mesh.ARRAY_INDEX].append(i + 7 + HexHelper.get_opposite_hex_direction(direction))
			arrays[Mesh.ARRAY_INDEX].append(i + 7 + HexHelper.get_opposite_hex_direction(next_dir))
			

func generate_mesh():
	_calculate_global_uv_ratio()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array()
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array()
	
	add_hexagons_to_geometry(arrays)
	add_connectors_to_grid(arrays)
	# Create the Mesh.
	$MeshInstance3D.mesh = ArrayMesh.new()
	$MeshInstance3D.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	for c in $MeshInstance3D.get_children():
		$MeshInstance3D.remove_child(c)
	$MeshInstance3D.create_multiple_convex_collisions()
