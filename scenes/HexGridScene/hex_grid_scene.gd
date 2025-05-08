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
	
	var last_major_hex = null
	for i in range(size):
		var hex = Hexagon.new()
		hex.hex_position = start_pos.duplicate()
		hex.height = hex.hex_position.distance_to(HexHelper.HexCoordinate.new(0,0,0))
		if(last_major_hex != null):
			hex.add_neighbor(last_major_hex) 
			hex.add_neighbor(hexagons[len(hexagons) - (size - i - 1) - 1])
		last_major_hex = hex
		hexagons.append(hex)
		var step_pos = start_pos.duplicate()
		start_pos.step_in_dir(direction)
		step_pos.step_in_dir(next_dir)
		var last_minor_hex = hex
		for j in range(size - i - 1):
			hex = Hexagon.new()
			hex.hex_position = step_pos.duplicate()
			hex.height = hex.hex_position.distance_to(HexHelper.HexCoordinate.new(0,0,0))
			hex.add_neighbor(last_minor_hex)
			if (size - (i - 1)) <= len(hexagons):
				hex.add_neighbor(hexagons[len(hexagons) - (size - (i - 1))])
				hex.add_neighbor(hexagons[len(hexagons) - (size - (i - 1)) + 1])
			last_minor_hex = hex
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
	for h in hexagons:
		for n in [HexHelper.HexDirection.NE, HexHelper.HexDirection.E, HexHelper.HexDirection.SE]:
			var o = h.get_neighbor_in_dir(n)
			if o != null and o in hexagons:
				#I can probably inline this, but i am lazy and don't understand my own helper functions anymore
				if n == HexHelper.HexDirection.NE:
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 3)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 4)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 1)
					
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 4)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 6)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 1)
				elif n == HexHelper.HexDirection.E:
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 4)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 5)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 1)
					
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 2)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 4)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 1)
				elif n == HexHelper.HexDirection.SE:
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 5)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 6)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 2)
					
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 5)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 2)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 3)
	
func generate_triangles(arrays):
	for h in hexagons:
		var a = h.get_neighbor_in_dir(HexHelper.HexDirection.NE)
		var b = h.get_neighbor_in_dir(HexHelper.HexDirection.E)
		var c = h.get_neighbor_in_dir(HexHelper.HexDirection.SE)
		
		if b == null or not b in hexagons:
			continue
		
		if a != null and a in hexagons:
			arrays[Mesh.ARRAY_INDEX].append(hexagons.find(b) * 7 + 2)
			arrays[Mesh.ARRAY_INDEX].append(hexagons.find(a) * 7 + 6)
			arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 4)
		if c != null and c in hexagons:
			arrays[Mesh.ARRAY_INDEX].append(hexagons.find(c) * 7 + 3)
			arrays[Mesh.ARRAY_INDEX].append(hexagons.find(b) * 7 + 1)
			arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 5)
	

func generate_chunk_border_in_dir(arrays, direction:HexHelper.HexDirection):
	var start_pos = HexHelper.HexCoordinate.new(0, 0, 0)
	start_pos = start_pos.step_in_dir(direction)
	var dir = HexHelper.get_opposite_hex_direction(HexHelper.get_next_hex_direction(direction))
	
	var pos = start_pos.step_in_dir(dir)
	for j in range(size):
		if direction == HexHelper.HexDirection.NE:
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 1)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
			arrays[Mesh.ARRAY_INDEX].append(0)
			
			arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() + Vector3( HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0,  0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() + Vector3( HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0, -0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			
			arrays[Mesh.ARRAY_TEX_UV].append(Vector2())
			arrays[Mesh.ARRAY_TEX_UV].append(Vector2())

func generate_mesh():
	_calculate_global_uv_ratio()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array()
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array()
	
	add_hexagons_to_geometry(arrays)
	add_connectors_to_grid(arrays)
	generate_triangles(arrays)
	generate_chunk_border_in_dir(arrays, HexHelper.get_prev_hex_direction(direction))
	# Create the Mesh.
	$MeshInstance3D.mesh = ArrayMesh.new()
	$MeshInstance3D.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	for c in $MeshInstance3D.get_children():
		$MeshInstance3D.remove_child(c)
	$MeshInstance3D.create_multiple_convex_collisions()
