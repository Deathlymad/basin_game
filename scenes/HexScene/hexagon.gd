extends Node3D

class_name Hexagon

var height : float
var _hex_position : HexHelper.HexCoordinate
var neighbors : Array[Hexagon]


func _get_property_list():
	return [
		{
			"name" : "Hex Coordinate", 
			"type" : TYPE_VECTOR3, 
			"usage":PROPERTY_USAGE_DEFAULT
		}
	]
func _get(_prop):
	return _hex_position.pos
func _set(_prop, val):
	if _hex_position:
		_hex_position.pos = val
		return true
	return false

func get_hex_position():
	return _hex_position
func set_hex_position(p):
	_hex_position = p

func add_neighbor(hex : Hexagon, propagate:bool = true):
	if not hex in neighbors:
		if propagate:
			hex.add_neighbor(self, false)
		neighbors.append(hex)
	else:
		pass
func remove_neighbor(hex : Hexagon, propagate:bool = true):
	if hex in neighbors:
		if propagate:
			hex.remove_neighbor(self, false)
		neighbors.erase(hex)
func get_neighbor_in_dir(dir : HexHelper.HexDirection):
	for hex in neighbors:
		if _hex_position.duplicate().minus(hex._hex_position).get_direction() == dir:
			return hex

func _update_mesh(uv_ratio : Vector2, uv_offset : Vector2, coord_offset : Vector3 = Vector3.ZERO, idx_offset : int = 0):
	var pts : Array[Vector3] = []
	
	pts.append(coord_offset + Vector3.UP * height) #Center
	
	pts.append(coord_offset + Vector3(  HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, height,  0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
	pts.append(coord_offset + Vector3(  HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, height, -0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
	pts.append(coord_offset + Vector3(                       0, height,       -HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
	pts.append(coord_offset + Vector3( -HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, height, -0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
	pts.append(coord_offset + Vector3( -HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, height,  0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
	pts.append(coord_offset + Vector3(                       0, height,        HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
	
	var idx : Array[int] = []
	
	for i in range(1, 7):
		idx.append(idx_offset)
		if i + 1 < 7:
			idx.append(idx_offset + (i + 1))
		else:
			idx.append(idx_offset + 1)
		idx.append(idx_offset + i)
	
	var uvs : Array[Vector2] = []
	
	for point in pts:
		var pt = Vector2(point.x, point.z)
		var local_norm_uv = (pt + uv_offset) / uv_ratio
		var new_uv = local_norm_uv + (uv_ratio/2)
		
		uvs.append(new_uv)
		
	
	return [pts, idx, uvs]
