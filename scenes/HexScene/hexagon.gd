extends Node3D

class_name Hexagon

var height : float
var hex_position : HexHelper.HexCoordinate

var normalizedUV : Vector2
var uv_offset = Vector2.ZERO
var grid_radius

func _calculate_uv():
	var hex_pos = hex_position
	
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
	var grid_scale = 1.0 / float(grid_radius * 2)
	
	for point in pts:		
		var local_norm_uv = Vector2(point.x, point.z) * grid_scale
		var new_uv = local_norm_uv + uv_offset
		
		uvs.append(new_uv)
	
	return [pts, idx, uvs]
