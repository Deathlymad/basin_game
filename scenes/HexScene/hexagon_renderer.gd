extends MeshInstance3D

var normalizedUV : Vector2
var uv_offset = Vector2.ZERO
var grid_radius

func _ready():
	
	_calculate_uv()
	var res = _update_mesh()
	apply_update_to_mesh(res[0], res[1], res[2])
	
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = preload("res://assets/textures/checkermap.png")
	mesh.surface_set_material(0, mat)


func _calculate_uv():
	var hex_pos = get_parent().hex_position
	grid_radius = get_parent().get_parent().radius
	
	var x = hex_pos.pos.x
	var z = hex_pos.pos.z
	
	var MAX_ARRAY : Array[Vector3]
	
	MAX_ARRAY.append(HexHelper.HexCoordinate.new(0,0,grid_radius).to_carthesian())
	MAX_ARRAY.append(HexHelper.HexCoordinate.new(grid_radius,0,0).to_carthesian())
	MAX_ARRAY.append(HexHelper.HexCoordinate.new(0,0,-grid_radius).to_carthesian())
	MAX_ARRAY.append(HexHelper.HexCoordinate.new(-grid_radius,0,0).to_carthesian())
	MAX_ARRAY.append(HexHelper.HexCoordinate.new(0,grid_radius,0).to_carthesian())	
	MAX_ARRAY.append(HexHelper.HexCoordinate.new(0,-grid_radius,0).to_carthesian())
	
	var min
	var max
		
		
		
	
	print(uv_offset)
	

func _update_mesh(coord_offset : Vector3 = Vector3.ZERO, idx_offset : int = 0):
	var pts : Array[Vector3] = []
	
	
	pts.append(Vector3.ZERO) #Center
	
	pts.append(Vector3(  HexHelper.INNER_RADIUS, 0,  0.5 * HexHelper.OUTER_RADIUS), )
	pts.append(Vector3(  HexHelper.INNER_RADIUS, 0, -0.5 * HexHelper.OUTER_RADIUS))
	pts.append(Vector3(                       0, 0,       -HexHelper.OUTER_RADIUS))
	pts.append(Vector3( -HexHelper.INNER_RADIUS, 0, -0.5 * HexHelper.OUTER_RADIUS))
	pts.append(Vector3( -HexHelper.INNER_RADIUS, 0,  0.5 * HexHelper.OUTER_RADIUS))
	pts.append(Vector3(                       0, 0,        HexHelper.OUTER_RADIUS))
	
	
	
	var idx : Array[int] = []
	
	
	for i in range(1, 7):
		idx.append(0)
		if i + 1 < 7:
			idx.append((i + 1))
		else:
			idx.append(1)
		idx.append(i)
		
		
	var uvs : Array[Vector2] = []
	var grid_scale = 1.0 / float(grid_radius * 2)
	
	for point in pts:		
		var local_norm_uv = Vector2(point.x, point.z) * grid_scale
		var new_uv = local_norm_uv + uv_offset
		
		uvs.append(new_uv)
	
	return [pts, idx, uvs]

func apply_update_to_mesh(vertices, indices, uvs):
	var packed_coords : PackedVector3Array = PackedVector3Array()
	packed_coords.append_array(vertices)
	var packed_idx : PackedInt32Array = PackedInt32Array()
	packed_idx.append_array(indices)
	var packed_uvs : PackedVector2Array = PackedVector2Array()
	packed_uvs.append_array(uvs)
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = packed_coords
	arrays[Mesh.ARRAY_INDEX] = packed_idx
	arrays[Mesh.ARRAY_TEX_UV] = packed_uvs
	
	# Create the Mesh.
	mesh.clear_surfaces()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	for c in get_children():
		remove_child(c)
	create_multiple_convex_collisions()
