extends MeshInstance3D

var normalizedUV : Vector2
var uv_offset = Vector2.ZERO

func _ready():
	
	_calculate_uv()
	var res = _update_mesh(Vector3.ZERO, 0, Vector2())
	apply_update_to_mesh(res[0], res[1])


func _calculate_uv():
	var hex_pos = get_parent().hex_position
	var grid_radius = get_parent().get_parent().radius
	
	var x = hex_pos.pos.x
	var y = hex_pos.pos.y
	var z = hex_pos.pos.z
	
	var u = (3.0/2.0 * x + 3.0/2.0 * y + 0.0 * z) / (3.0 * grid_radius)
	var v = (sqrt(3)/2.0 * x - sqrt(3)/2.0 * y + sqrt(3) * z) / (3.0 * grid_radius)

	uv_offset = Vector2(u + 0.5, v + 0.5)


func _update_mesh(coord_offset : Vector3 = Vector3.ZERO, idx_offset : int = 0, uv_offset: Vector2 = Vector2.ZERO):
	var pts : Array[Vector3] = []
	
	pts.append(Vector3.ZERO) #Center
	
	pts.append(Vector3(  HexHelper.INNER_RADIUS, 0,  0.5 * HexHelper.OUTER_RADIUS))
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
	
	return [pts, idx]

func apply_update_to_mesh(vertices, indices):
	var packed_coords : PackedVector3Array = PackedVector3Array()
	packed_coords.append_array(vertices)
	var packed_idx : PackedInt32Array = PackedInt32Array()
	packed_idx.append_array(indices)
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = packed_coords
	arrays[Mesh.ARRAY_INDEX] = packed_idx
	
	# Create the Mesh.
	mesh.clear_surfaces()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	for c in get_children():
		remove_child(c)
	create_multiple_convex_collisions()
