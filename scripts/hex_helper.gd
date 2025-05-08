extends Node

class_name HexHelper

static var OUTER_RADIUS : float = 1;
static var INNER_RADIUS : float = OUTER_RADIUS * 0.866025404;

enum HexDirection {
	NE,
	E,
	SE,
	SW,
	W,
	NW
}

class HexCoordinate:
	static var ORIGIN = HexCoordinate.new(0, 0, 0)
	var pos : Vector3
	
	func _init(x : float, y : float, z : float):
		pos.x = x
		pos.z = z
	
	func to_carthesian() -> Vector3:
		var x = (sqrt(3) * pos.x + sqrt(3)/2 * pos.z) * HexHelper.OUTER_RADIUS;
		var z =  pos.z * HexHelper.OUTER_RADIUS * 1.5;
		return Vector3(x, 0, z)
	
	func round_coord():
		var q = round(pos.x)
		var r = round(pos.z)
		var s = round(-pos.x - pos.z)

		var q_diff = abs(q - pos.x)
		var r_diff = abs(r - pos.y)
		var s_diff = abs(s + pos.x + pos.z)

		if q_diff > r_diff and q_diff > s_diff:
			q = -r-s
		elif r_diff > s_diff:
			r = -q-s
		pos.x = q
		pos.z = r
	
	static func from_carthesian(coord : Vector3) -> HexCoordinate:
		var x = coord.x / HexHelper.OUTER_RADIUS
		var z = coord.z / HexHelper.OUTER_RADIUS
		
		var a = (sqrt(3)/3 * x  -  1./3 * z)
		var b = 2./3 * z
		
		
		return HexCoordinate.new(a, 0, b)
	
	func distance_to(other : HexCoordinate):
		return (
			abs(pos.x - other.pos.x) + 
			abs(pos.x + pos.z - other.pos.x - other.pos.z) + 
			abs(pos.z - other.pos.z)) / 2
	
	func _to_string() -> String:
		return "(" + str(pos.x) + ", " + str(pos.y) + ", " + str(pos.z) + ")"
