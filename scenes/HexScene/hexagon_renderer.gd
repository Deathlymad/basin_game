extends MeshInstance3D


func _ready():
	var res = _update_mesh(get_parent().height)
	apply_update_to_mesh(res[0], res[1])

func _update_mesh(height : float = 0, coord_offset : Vector3 = Vector3.ZERO, idx_offset : int = 0):
	var pts : Array[Vector3] = []
	
	pts.append(Vector3.ZERO) #Center
	
	pts.append(Vector3(  HexHelper.INNER_RADIUS, height,  0.5 * HexHelper.OUTER_RADIUS))
	pts.append(Vector3(  HexHelper.INNER_RADIUS, height, -0.5 * HexHelper.OUTER_RADIUS))
	pts.append(Vector3(                       0, height,       -HexHelper.OUTER_RADIUS))
	pts.append(Vector3( -HexHelper.INNER_RADIUS, height, -0.5 * HexHelper.OUTER_RADIUS))
	pts.append(Vector3( -HexHelper.INNER_RADIUS, height,  0.5 * HexHelper.OUTER_RADIUS))
	pts.append(Vector3(                       0, height,        HexHelper.OUTER_RADIUS))
	
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
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINE_STRIP, arrays)
