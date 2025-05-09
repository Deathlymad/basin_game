extends Node3D

@export var hexgrid_radius : int
var pathing : AStar2D
func _enter_tree():
	for c in get_children():
		if not c is MeshInstance3D:
			c.size = hexgrid_radius
			
func _ready():
	for c in get_children():
		if not c is MeshInstance3D:
			c.build_chunk_neighborhood()
	build_pathing()
	
func get_id_from_hex_coord(coord):
	return  coord.pos.x * 1024 + 128 * 1024 + coord.pos.z + 128


func build_pathing():
	pathing = AStar2D.new()
	var m = null
	for c in get_children():
		if c is MeshInstance3D:
			m = c
			break
	
	var lines = []
	
	for c in get_children():
		if not c is MeshInstance3D:
			for h in c.hexagons:
				for n in h.neighbors:
					var id = get_id_from_hex_coord(h.get_hex_position())
					if not pathing.has_point(id):
						pathing.add_point(id, HexHelper.to_xz(h.get_hex_position().to_carthesian()))
					var id1 = get_id_from_hex_coord(n.get_hex_position())
					if not pathing.has_point(id1):
						pathing.add_point(id1, HexHelper.to_xz(n.get_hex_position().to_carthesian()))
					if not pathing.are_points_connected(id, id1):
						pathing.connect_points(id, id1)

func compute_path(start, end):
	if not pathing.has_point(get_id_from_hex_coord(start)) or not pathing.has_point(get_id_from_hex_coord(end)):
		return []
	var pth = pathing.get_id_path(get_id_from_hex_coord(start), get_id_from_hex_coord(end))
	
	var res = []
	for p in pth:
		res.append(HexHelper.HexCoordinate.new(p / 1024 - 128, 0, p % 1024 - 128))
	return res
	


func generate_neighborhood_graph():
	var m = null
	for c in get_children():
		if c is MeshInstance3D:
			m = c
			break
	
	var lines = []
	
	var hs = []
	for c in get_children():
		if not c is MeshInstance3D:
			for h in c.hexagons:
				for n in h.neighbors:
					if n.get_hex_position() in hs:
						continue
					else:
						hs.append(h.get_hex_position())
					lines.append(h.get_hex_position().to_carthesian())
					lines.append(n.get_hex_position().to_carthesian())
	
	m.mesh.clear_surfaces()
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	arrays[Mesh.ARRAY_VERTEX].append_array(lines)
	m.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_released("debug"):
			generate_neighborhood_graph()

func get_chunk_by_direction(dir : HexHelper.HexDirection):
	for c in get_children():
		if not c is MeshInstance3D:
			if c.direction == dir:
				return c


func get_hexagon_from_hex_coord(coord : HexHelper.HexCoordinate):
	for c in get_children():
		if not c is MeshInstance3D:
			var tmp = c.contains(coord)
			if tmp:
				return c.get_hexagon(coord)
	return null
