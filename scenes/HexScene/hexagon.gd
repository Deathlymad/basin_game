extends Node3D

class_name Hexagon

var height : float
var hex_position : HexHelper.HexCoordinate

var uv_offset = Vector2.ZERO
var grid_radius
var grid_range

func _calculate_uv():
	
	var MAX_ARRAY : Array[Vector3]
	
	MAX_ARRAY.append(HexHelper.HexCoordinate.new(0,0,grid_radius).to_carthesian())
	MAX_ARRAY.append(HexHelper.HexCoordinate.new(grid_radius,0,0).to_carthesian())
	MAX_ARRAY.append(HexHelper.HexCoordinate.new(0,0,-grid_radius).to_carthesian())
	MAX_ARRAY.append(HexHelper.HexCoordinate.new(-grid_radius,0,0).to_carthesian())
	MAX_ARRAY.append(HexHelper.HexCoordinate.new(0,grid_radius,0).to_carthesian())	
	MAX_ARRAY.append(HexHelper.HexCoordinate.new(0,-grid_radius,0).to_carthesian())
	
	var min = Vector2.ZERO
	var max = Vector2.ZERO
	
	for pt in MAX_ARRAY:
		min.x = min(pt.x, min.x)
		min.y = min(pt.z, min.y)
		max.x = max(pt.x, max.y)
		max.y = max(pt.z, max.y)
	
	grid_range = max - min
	
	
	
	print(uv_offset)
	
func _update_mesh(coord_offset : Vector3 = Vector3.ZERO, idx_offset : int = 0):
	_calculate_uv()
	var pts : Array[Vector3] = []
	
	pts.append(coord_offset) #Center
	
	pts.append(coord_offset + Vector3(  HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0,  0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
	pts.append(coord_offset + Vector3(  HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0, -0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
	pts.append(coord_offset + Vector3(                       0, 0,       -HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
	pts.append(coord_offset + Vector3( -HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0, -0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
	pts.append(coord_offset + Vector3( -HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0,  0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
	pts.append(coord_offset + Vector3(                       0, 0,        HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
	
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
		var local_norm_uv = Vector2(point.x / grid_range.x, point.z / grid_range.y)
		var new_uv = local_norm_uv + (grid_range/2)
		
		uvs.append(new_uv)
		
	
	return [pts, idx, uvs]
