extends Node

class_name HexHelper

static var SOLID_RADIUS : float = 0.75
static var OUTER_RADIUS : float = 4;
static var INNER_RADIUS : float = OUTER_RADIUS * 0.866025404;

enum HexDirection {
	NE = 0,
	E = 1,
	SE = 2,
	SW = 3,
	W = 4,
	NW = 5,
	DIRECTION_MAX = 6
}
#clockwise
static func get_next_hex_direction(dir : HexDirection):
	return (dir + 1) % HexDirection.DIRECTION_MAX
static func get_prev_hex_direction(dir : HexDirection):
	return (HexDirection.DIRECTION_MAX + dir - 1) % HexDirection.DIRECTION_MAX
static func get_opposite_hex_direction(dir : HexDirection):
	return (dir + 4) % HexDirection.DIRECTION_MAX

static func to_xz(v : Vector3) -> Vector2:
	return Vector2(v.x, v.z)

class HexCoordinate:
	var pos : Vector3
	
	func _init(x : float, _y : float, z : float):
		pos.x = x
		pos.z = z
	
	func duplicate():
		return HexCoordinate.new(pos.x, pos.y, pos.z)
	
	func get_direction():
		round_coord()
		if abs(pos.x + pos.z) > 1:
			print("ERROR: attempted to compute direction on non-normalized coordinate")
		else:
			if pos.z == 1 and pos.x == 0:
				return HexDirection.NE
			elif pos.x == 1 and pos.z == 0:
				return HexDirection.E
			elif pos.x == 1 and pos.z == -1:
				return HexDirection.SE
			elif pos.z == -1 and pos.z == 0:
				return HexDirection.SW
			elif pos.x == -1 and pos.z == 0:
				return HexDirection.W
			elif pos.x == -1 and pos.z == 1:
				return HexDirection.NW
			
	
	func step_in_dir(dir : HexDirection):
		if dir == HexDirection.NE:
			pos.z += 1
		elif dir == HexDirection.E:
			pos.x += 1
		elif dir == HexDirection.SE:
			pos.x += 1
			pos.z -= 1
		elif dir == HexDirection.SW:
			pos.z -= 1
		elif dir == HexDirection.W:
			pos.x -= 1
		elif dir == HexDirection.NW:
			pos.x -= 1
			pos.z += 1
		return self
	
	func minus(other : HexCoordinate):
		pos.x -= other.pos.x
		pos.z -= other.pos.z
		return self
	
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
	
	func matches(other : HexCoordinate):
		return pos == other.pos
	
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
