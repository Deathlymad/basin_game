extends Node3D

class_name Hexagon

var height : float
var hex_position : HexHelper.HexCoordinate

func _update_mesh(coord_offset : Vector3 = Vector3.ZERO, idx_offset : int = 0):
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
	
	return [pts, idx]
