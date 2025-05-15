extends Node3D

var hexagons : Array[Hexagon]
@export var direction : HexHelper.HexDirection


var geometry_arrays


func _ready():
	hexagons = []
	var start_pos = HexHelper.HexCoordinate.new(0, 0, 0)
	var next_dir = HexHelper.get_next_hex_direction(direction)
	start_pos = start_pos.step_in_dir(direction)
	var size = get_parent().hexgrid_radius
	for i in range(size):
		var hex = Hexagon.new(start_pos.duplicate())
		if(i > 0):
			hex.add_neighbor(hexagons[len(hexagons) - (size - i - 1) - 1])
			hex.add_neighbor(hexagons[len(hexagons) - (size - i - 1) - 2])
		hexagons.append(hex)
		hex.position = hex.hex_position.to_carthesian() + Vector3.UP * hex.tile_height
		add_child(hex)
		var step_pos = start_pos.duplicate()
		start_pos.step_in_dir(direction)
		step_pos.step_in_dir(next_dir)
		for j in range(size - i - 1):
			hex = Hexagon.new(step_pos.duplicate())
			hex.add_neighbor(hexagons[len(hexagons) - 1])
			if(i > 0):
				hex.add_neighbor(hexagons[len(hexagons) - (size - i - 1) - 1])
				hex.add_neighbor(hexagons[len(hexagons) - (size - i - 1) - 2])
			hexagons.append(hex)
			hex.position = hex.hex_position.to_carthesian() + Vector3.UP * hex.tile_height
			add_child(hex)
			step_pos.step_in_dir(next_dir)
	
	generate_mesh()

func contains(coord : HexHelper.HexCoordinate) -> bool:
	#TODO this can be solved in constant time with coordinate calculation of chunk extremes
	for h in hexagons:
		if coord.matches(h.get_hex_position()):
			return true
	return false
func get_hexagon(coord : HexHelper.HexCoordinate) -> Hexagon:
	for h in hexagons:
		if coord.matches(h.get_hex_position()):
			return h
	return null

func build_chunk_neighborhood():
	var start_pos = HexHelper.HexCoordinate.new(0, 0, 0)
	start_pos = start_pos.step_in_dir(HexHelper.get_prev_hex_direction(direction))
	
	var pos = start_pos.duplicate()
	var off = 0
	var last_off = -1
	var size = get_parent().hexgrid_radius
	for j in range(size):
		var h = Hexagon.HexagonLookup[pos.pos]
		if last_off > -1:
			hexagons[last_off].add_neighbor(h)
		hexagons[off].add_neighbor(h)
		last_off = off
		off += size - j
		pos.step_in_dir(direction)

#Rendering Code

func add_hexagons_to_geometry(arrays):
	var size = get_parent().hexgrid_radius
	for hex in hexagons:
		var res = hex._generate_mesh(get_parent().uv_ratio,get_parent().uv_offset, hex.hex_position.to_carthesian(), arrays[Mesh.ARRAY_VERTEX].size())
		arrays[Mesh.ARRAY_VERTEX].append_array(res[0])
		arrays[Mesh.ARRAY_INDEX].append_array(res[1])
		arrays[Mesh.ARRAY_TEX_UV].append_array(res[2])
		arrays[Mesh.ARRAY_CUSTOM0].append_array(res[3])
	
func add_connectors_to_grid(arrays):
	for h in hexagons:
		for n in [HexHelper.HexDirection.NE, HexHelper.HexDirection.E, HexHelper.HexDirection.SE]:
			var o = h.get_neighbor_in_dir(n)
			if o != null and o in hexagons:
				
				var h_offset = n * 4
				var o_offset = (n + 3) * 4
				
				for i in range(4):
					arrays[Mesh.ARRAY_INDEX].append(h.outside_indices[(h_offset - i) % len(h.outside_indices)])
					arrays[Mesh.ARRAY_INDEX].append(o.outside_indices[(o_offset - (4 - i)) % len(o.outside_indices)])
					arrays[Mesh.ARRAY_INDEX].append(h.outside_indices[(h_offset - (i + 1)) % len(h.outside_indices)])
					
					arrays[Mesh.ARRAY_INDEX].append(o.outside_indices[(o_offset - (4 - i)) % len(o.outside_indices)])
					arrays[Mesh.ARRAY_INDEX].append(h.outside_indices[(h_offset - (i + 1)) % len(h.outside_indices)])
					arrays[Mesh.ARRAY_INDEX].append(o.outside_indices[(o_offset - (3 - i)) % len(o.outside_indices)])
	

func generate_triangles(arrays):
	for h in hexagons:
		var a = h.get_neighbor_in_dir(HexHelper.HexDirection.NE)
		var b = h.get_neighbor_in_dir(HexHelper.HexDirection.E)
		var c = h.get_neighbor_in_dir(HexHelper.HexDirection.SE)
		
		if b == null or not b in hexagons:
			continue
		
		if a != null and a in hexagons:
			arrays[Mesh.ARRAY_INDEX].append(b.outside_indices[16])
			arrays[Mesh.ARRAY_INDEX].append(a.outside_indices[8])
			arrays[Mesh.ARRAY_INDEX].append(h.outside_indices[0])
		if c != null and c in hexagons:
			arrays[Mesh.ARRAY_INDEX].append(c.outside_indices[20])
			arrays[Mesh.ARRAY_INDEX].append(b.outside_indices[12])
			arrays[Mesh.ARRAY_INDEX].append(h.outside_indices[4])
	
func generate_chunk_border_in_dir(arrays, d:HexHelper.HexDirection):
	var _start_pos = HexHelper.HexCoordinate.new(0, 0, 0)
	_start_pos = _start_pos.step_in_dir(d)
	var _dir = HexHelper.get_next_hex_direction(d)
	
	var _size = get_parent().hexgrid_radius
	var _uv_ratio = get_parent().uv_ratio
	
	var _pos = _start_pos.duplicate()
	
	for i in range(_size):
		if i == 0:
			pass #TODO
		else:
			pass
		
		#arrays[Mesh.ARRAY_VERTEX]
		

func generate_mesh():
	if geometry_arrays == null:
		geometry_arrays = []
		geometry_arrays.resize(Mesh.ARRAY_MAX)
		geometry_arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array()
		geometry_arrays[Mesh.ARRAY_INDEX] = PackedInt32Array()
		geometry_arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array()
		geometry_arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array()
		geometry_arrays[Mesh.ARRAY_CUSTOM0] = PackedFloat32Array()
	
	add_hexagons_to_geometry(geometry_arrays)
	add_connectors_to_grid(geometry_arrays)
	generate_triangles(geometry_arrays)
	#generate_chunk_border_in_dir(geometry_arrays, HexHelper.get_prev_hex_direction(direction))
	
	for v in range(geometry_arrays[Mesh.ARRAY_VERTEX].size()):
		geometry_arrays[Mesh.ARRAY_NORMAL].append(Vector3.ZERO)
	
	# Create the Mesh.
	$MeshInstance3D.mesh = ArrayMesh.new()
	$MeshInstance3D.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, geometry_arrays, [], {}, Mesh.ARRAY_CUSTOM_RG_FLOAT << Mesh.ARRAY_FORMAT_CUSTOM0_SHIFT )
	geometry_arrays[Mesh.ARRAY_NORMAL].clear()
	for c in $MeshInstance3D.get_children():
		$MeshInstance3D.remove_child(c)
	$MeshInstance3D.create_multiple_convex_collisions()
	
	var mdt = MeshDataTool.new()
	mdt.create_from_surface($MeshInstance3D.mesh, 0)
	for i in range(mdt.get_vertex_count()):
		mdt.set_vertex_normal(i, Vector3.ZERO)
		
	for i in range(mdt.get_face_count()):
		var facevert1 = mdt.get_face_vertex(i,0)
		var facevert2 = mdt.get_face_vertex(i,1)
		var facevert3 = mdt.get_face_vertex(i,2)
		
		var vert1 = mdt.get_vertex(facevert1)
		var vert2 = mdt.get_vertex(facevert2)
		var vert3 = mdt.get_vertex(facevert3)
		
		var normal = Plane(vert1, vert2, vert3).normal
		
		mdt.set_vertex_normal(facevert1, mdt.get_vertex_normal(facevert1) + normal)
		mdt.set_vertex_normal(facevert2, mdt.get_vertex_normal(facevert2) + normal)
		mdt.set_vertex_normal(facevert3, mdt.get_vertex_normal(facevert3) + normal)
		
	for i in range(mdt.get_vertex_count()):
		var nor = mdt.get_vertex_normal(i)
		mdt.set_vertex_normal(i, nor.normalized())
		geometry_arrays[Mesh.ARRAY_NORMAL].append(nor)
	$MeshInstance3D.mesh.clear_surfaces()
	mdt.commit_to_surface($MeshInstance3D.mesh)
	
	$MeshInstance3D.mesh.clear_surfaces()
	$MeshInstance3D.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, geometry_arrays, [], {}, Mesh.ARRAY_CUSTOM_RG_FLOAT << Mesh.ARRAY_FORMAT_CUSTOM0_SHIFT )
	
func update_mesh_water_data():
	for h in hexagons:
		h.update_custom_props(geometry_arrays)
	
	$MeshInstance3D.mesh.clear_surfaces()
	$MeshInstance3D.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, geometry_arrays, [], {}, Mesh.ARRAY_CUSTOM_RG_FLOAT << Mesh.ARRAY_FORMAT_CUSTOM0_SHIFT )
	
