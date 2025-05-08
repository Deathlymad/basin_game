extends Node

class_name HexHelper

static var OUTER_RADIUS : float = 1;
static var INNER_RADIUS : float = OUTER_RADIUS * 0.866025404;

class HexCoordinate:
	var pos : Vector3
	
	func _init(x : float, y : float, z : float):
		pos.x = x
		pos.y = y
		pos.z = z
	
	func to_carthesian() -> Vector3:
		var x = (2 * pos.x + pos.y - pos.z) * HexHelper.INNER_RADIUS * 1;
		var z =  (pos.y + pos.z) * 3/2 * HexHelper.OUTER_RADIUS;
		return Vector3(x, 0, z)
	
	func to_coord_string():
		return "(" + str(pos.x) + ", " + str(pos.y) + ", " + str(pos.z) + ")"
