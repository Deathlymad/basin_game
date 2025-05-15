extends Node3D

@export var hexgrid_radius : int
var pathing : AStar2D

var uv_ratio : Vector2
var uv_offset : Vector2

func _enter_tree() -> void:
	_calculate_global_uv_ratio()

func _calculate_global_uv_ratio():
	
	var extremes : Array[Vector3]
	
	extremes.append(HexHelper.HexCoordinate.new(0,0,hexgrid_radius).to_carthesian())
	extremes.append(HexHelper.HexCoordinate.new(hexgrid_radius,0,0).to_carthesian())
	extremes.append(HexHelper.HexCoordinate.new(0,0,-hexgrid_radius).to_carthesian())
	extremes.append(HexHelper.HexCoordinate.new(-hexgrid_radius,0,0).to_carthesian())
	print(extremes)
	var mn = Vector2.ZERO
	var mx = Vector2.ZERO
	
	for pt in extremes:
		mn.x = min(pt.x, mn.x)
		mn.y = min(pt.z, mn.y)
		mx.x = max(pt.x, mx.x)
		mx.y = max(pt.z, mx.y)
	
	uv_ratio = mx - mn
	uv_offset = Vector2.ZERO - mn
	
var graph : WaterGraph = WaterGraph.new()

func _ready():
	for c in get_children():
		if c.is_in_group("chunk_group"):
			c.build_chunk_neighborhood()
	build_pathing()
	$Timer.timeout.connect(update_graph)

func update_graph():
	var pos = [
		Vector3(1,0,0),
		Vector3(0,0,1),
		Vector3(-1,0,1),
		Vector3(1,0,-1),
		Vector3(-1,0,0),
		Vector3(0,0,-1),
	]
	for h in pos:
		Hexagon.HexagonLookup[h].water_node.content.water = 5
	graph.update()
	for h in pos:
		Hexagon.HexagonLookup[h].water_node.content.water = 5
	for c in get_children():
		if c.is_in_group("chunk_group"):
			c.update_mesh_water_data()

func get_id_from_hex_coord(coord):
	return  coord.pos.x * 1024 + 128 * 1024 + coord.pos.z + 128

func build_pathing():
	pathing = AStar2D.new()
	
	for c in get_children():
		if c.is_in_group("chunk_group"):
			for h in c.hexagons:
				for n in h.neighbors:
					var id = get_id_from_hex_coord(h.hex_position)
					if not pathing.has_point(id):
						pathing.add_point(id, HexHelper.to_xz(h.hex_position.to_carthesian()))
					var id1 = get_id_from_hex_coord(n.hex_position)
					if not pathing.has_point(id1):
						pathing.add_point(id1, HexHelper.to_xz(n.hex_position.to_carthesian()))
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
	var colors = []
	
	var hs = []
	for c in get_children():
		if c.is_in_group("chunk_group"):
			for h in c.hexagons:
				for n in h.neighbors:
					if n.hex_position.pos in hs:
						continue
					else:
						hs.append(h.hex_position.pos)
					lines.append(h.hex_position.to_carthesian())
					lines.append(n.hex_position.to_carthesian())
					colors.append(Color(0,0,0))
					colors.append(Color(0,0,0))
	lines.clear()
	colors.clear()
	for n in graph.nodes:
		for n1 in n.destinations:
			#if n1.source.pos.pos.y == 12 or n1.dest.pos.pos.y == 12:
				lines.append(n1.source.pos.to_carthesian() + Vector3.UP * n1.source.pos.pos.y)
				lines.append(n1.source.pos.to_carthesian() + (n1.dest.pos.to_carthesian() - n1.source.pos.to_carthesian()) * 2 / 3 + Vector3.UP * n1.dest.pos.pos.y)
				colors.append(Color(32,32,128))
				colors.append(Color(0,64,255))
	
	m.mesh.clear_surfaces()
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	arrays[Mesh.ARRAY_COLOR] = PackedColorArray()
	arrays[Mesh.ARRAY_VERTEX].append_array(lines)
	arrays[Mesh.ARRAY_COLOR].append_array(colors)
	m.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays, [], {}, Mesh.ArrayFormat.ARRAY_FORMAT_COLOR)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_released("debug"):
			generate_neighborhood_graph()

func get_chunk_by_direction(dir : HexHelper.HexDirection):
	for c in get_children():
		if c.is_in_group("chunk_group"):
			if c.direction == dir:
				return c
