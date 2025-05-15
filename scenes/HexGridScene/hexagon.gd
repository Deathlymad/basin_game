extends Node3D

class_name Hexagon

var tile_height : float:
	get:
		return hex_position.pos.y
var hex_position : HexHelper.HexCoordinate:
	get:
		if hex_position == null:
			return null
		return hex_position.duplicate()
	set(value):
		if hex_position != null:
			HexagonLookup[hex_position.pos] = null
		HexagonLookup[value.pos] = self
		hex_position = value
static var HexagonLookup : Dictionary[Vector3, Hexagon]
var neighbors : Array[Hexagon]

var vertex_count = 37
var outside_indices = []
var index_offset = -1

var debug_sphere

class AqueductNode:
	var water : WaterGraph.WaterNode
	var in_bits : int
	var out_bits : int
	var aque_model : MeshInstance3D
var nodes : Array[AqueductNode]
var aque_foundation : MeshInstance3D

var pump : MeshInstance3D


enum AQUEDUCT_DIRECTION {
	NE =  1,
	E  =  2,
	SE =  4,
	SW =  8,
	W  = 16,
	NW = 32,
	GROUND = 64
}

var water_node : WaterGraph.WaterNode
var last_water = 0.0
var last_pol = 0.0

func _init(pos : HexHelper.HexCoordinate):
	hex_position = pos
	water_node = WaterGraph.WaterNode.new(pos)

func _ready():
	var obj = MeshInstance3D.new()
	obj.mesh = SphereMesh.new()
	obj.material_override = StandardMaterial3D.new()
	obj.material_override.albedo_color = Color(0, 64, 255)
	obj.scale = Vector3.ZERO
	obj.position.y = 12 - position.y
	add_child(obj)
	debug_sphere = obj
	
	water_node.pos = hex_position
	water_node.pos.pos.y = hex_position.pos.y
	get_parent().get_parent().graph.add_node(water_node)
	
	for i in range(10):
		var o = AqueductNode.new()
		o.water = WaterGraph.WaterNode.new(hex_position)
		o.water.pos.pos.y = i * 2
		o.water.max_node_content = 50
		o.water.should_evaporate = false
		o.in_bits = 0
		o.out_bits = 0
		o.aque_model = MeshInstance3D.new()
		o.aque_model.scale = Vector3.ONE * 0.009
		o.aque_model.position.y = i - position.y + 5
		o.aque_model.material_override = StandardMaterial3D.new()
		o.aque_model.material_override.albedo_texture = load("res://assets/textures/wood.png")
		$/root/MainScene/Basin.graph.add_node(o.water)
		add_child(o.aque_model)
		nodes.append(o)

func _process(_delta: float) -> void:
	debug_sphere.scale = Vector3.ONE * nodes[6].water.content.water

func spawn_pump():
	if pump != null:
		return
	var max_height = 0
	for i in range(len(nodes)):
		if ((nodes[i].in_bits | nodes[i].out_bits) & 63) == 0:
			continue
		
		max_height = i
	
	if max_height == 0:
		return
	
	pump = MeshInstance3D.new()
	pump.mesh = CylinderMesh.new()
	add_child(pump)
	pump.scale.x = 4
	pump.scale.y = (max_height * 2 - tile_height) / 2 + 2
	pump.scale.z = 4
	pump.position.y = (max_height * 2 - tile_height) / 2 + 2
	
	var last = water_node
	
	for i in range(len(nodes)):
		if ((nodes[i].in_bits | nodes[i].out_bits) & 63) == 0:
			continue
		var conn : WaterGraph.WaterConnection = WaterGraph.WaterPumpConnection.new()
		conn.source = last
		conn.dest = nodes[i].water
		last.add_destination_neighbor(conn)
		last = nodes[i].water
	
func add_aqueduct_in_for_height(height, in_dir, other_obj, out_dir):
	
	var next_lower_water_node = water_node
	
	for i in range(height, 0, -1):
		if nodes[i].out_bits & 63 > 0:
			next_lower_water_node = nodes[i].water
			break
	var conn : WaterGraph.WaterConnection
	if nodes[height].out_bits == 0:
		nodes[height].out_bits |= 64
		conn = WaterGraph.WaterRunoffConnection.new(height * 2 - tile_height)
		conn.source = nodes[height].water
		conn.dest = next_lower_water_node
		nodes[height].water.add_destination_neighbor(conn)
	nodes[height].in_bits |= 1 << in_dir
	
	conn = WaterGraph.WaterConnection.new()
	conn.source = other_obj.nodes[height].water
	conn.dest = nodes[height].water
	nodes[height].water.add_source_neighbor(conn)
	
	for j in range(height, len(nodes)):
		if (other_obj.nodes[j].out_bits & 63) == 0 and (other_obj.nodes[j].out_bits & 64) > 0:
			
			next_lower_water_node = other_obj.water_node
			
			for i in range(height, 0, -1):
				if nodes[i].out_bits & 63 > 0:
					next_lower_water_node = other_obj.nodes[i].water
					break
			other_obj.nodes[j].water.remove_destination_neighbor(next_lower_water_node)
			
			conn = WaterGraph.WaterRunoffConnection.new(j * 2 - height * 2)
			conn.source = other_obj.nodes[j].water
			conn.dest = nodes[height].water
			other_obj.nodes[j].water.add_destination_neighbor(conn)
	
	other_obj.nodes[height].out_bits |= 1 << out_dir
	other_obj.update_aqueduct_model()
	update_aqueduct_model()

func update_aqueduct_model():
	var max_height = 0
	for i in range(len(nodes)):
		if ((nodes[i].in_bits | nodes[i].out_bits) & 63) == 0:
			continue
		
		max_height = i
		
		var data_obj
		if not ((nodes[i].in_bits | nodes[i].out_bits) & 63) in AqueductConstants.auqeduct_for_connection_bitset.keys():
			data_obj = AqueductConstants.auqeduct_for_connection_bitset[1]
		else:
			data_obj = AqueductConstants.auqeduct_for_connection_bitset[(nodes[i].in_bits | nodes[i].out_bits) & 63]
		nodes[i].aque_model.mesh = data_obj["obj"]
		nodes[i].aque_model.rotation_degrees.y = data_obj["rot"]
		
	if aque_foundation == null:
		aque_foundation = MeshInstance3D.new() #TODO instantiate correct model
		aque_foundation.mesh = CylinderMesh.new()
		add_child(aque_foundation)
	aque_foundation.scale.x = 1
	aque_foundation.scale.y = (max_height * 2 - tile_height) / 2
	aque_foundation.scale.z = 1
	aque_foundation.position.y = (max_height * 2 - tile_height) / 2
	
	

#func _process(delta: float) -> void:
	#debug_sphere.scale = Vector3.ONE * water_node.water_amt / 2

func add_neighbor(hex : Hexagon, propagate:bool = true):
	if not hex in neighbors:
		if propagate:
			hex.add_neighbor(self, false)
		neighbors.append(hex)
		
		if hex.tile_height <= tile_height:
			var conn : WaterGraph.WaterConnection = WaterGraph.WaterRunoffConnection.new((tile_height - hex.tile_height))
			conn.source = water_node
			conn.dest = hex.water_node
			water_node.add_destination_neighbor(conn)
		if hex.tile_height > tile_height:
			var conn : WaterGraph.WaterConnection = WaterGraph.WaterRunoffConnection.new(hex.tile_height - tile_height)
			conn.source = hex.water_node
			conn.dest = water_node
			water_node.add_source_neighbor(conn)
	else:
		pass
func remove_neighbor(hex : Hexagon, propagate:bool = true):
	if hex in neighbors:
		if propagate:
			hex.remove_neighbor(self, false)
		neighbors.erase(hex)
		#water_node.remove_neighbor(hex.water_node)
	
func get_neighbor_in_dir(dir : HexHelper.HexDirection):
	for hex in neighbors:
		var d = hex.hex_position.minus(hex_position).get_direction()
		
		if d == dir:
			return hex

func _generate_mesh(uv_ratio : Vector2, uv_offset : Vector2, coord_offset : Vector3 = Vector3.ZERO, idx_offset : int = 0):
	var pts : Array[Vector3] = []
	var uvs : Array[Vector2] = []
	var water_data : Array[float] = []
	
	index_offset = idx_offset
	
	pts.append(Vector3.ZERO) #Center
	
	
	#inner vertices
	#starting from top-right/NE
	pts.append(Vector3(  HexHelper.INNER_RADIUS       , 0,  0.5  * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_INNER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS       , 0,                              0) * HexHelper.SOLID_INNER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS       , 0, -0.5  * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_INNER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS *  0.5, 0, -0.75 * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_INNER_GEOMETRY_RADIUS)
	pts.append(Vector3(                              0, 0,        -HexHelper.OUTER_RADIUS) * HexHelper.SOLID_INNER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS * -0.5, 0, -0.75 * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_INNER_GEOMETRY_RADIUS)
	pts.append(Vector3( -HexHelper.INNER_RADIUS       , 0, -0.5  * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_INNER_GEOMETRY_RADIUS)
	pts.append(Vector3( -HexHelper.INNER_RADIUS       , 0,                              0) * HexHelper.SOLID_INNER_GEOMETRY_RADIUS)
	pts.append(Vector3( -HexHelper.INNER_RADIUS       , 0,  0.5  * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_INNER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS * -0.5, 0, 0.75  * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_INNER_GEOMETRY_RADIUS)
	pts.append(Vector3(                              0, 0,         HexHelper.OUTER_RADIUS) * HexHelper.SOLID_INNER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS *  0.5, 0, 0.75  * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_INNER_GEOMETRY_RADIUS)
	
	#outer vertices
	pts.append(Vector3(  HexHelper.INNER_RADIUS        , 0,  0.5   * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS        , 0,  0.25  * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS        , 0,                               0) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS        , 0, -0.25  * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS        , 0, -0.5   * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS *  0.75, 0, -0.625 * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS *  0.5 , 0, -0.75  * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS *  0.25, 0, -0.875 * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(                               0, 0,         -HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS * -0.25, 0, -0.875 * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS * -0.5 , 0, -0.75  * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS * -0.75, 0, -0.625 * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3( -HexHelper.INNER_RADIUS        , 0, -0.5   * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3( -HexHelper.INNER_RADIUS        , 0, -0.25  * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3( -HexHelper.INNER_RADIUS        , 0,                               0) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3( -HexHelper.INNER_RADIUS        , 0,  0.25  * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3( -HexHelper.INNER_RADIUS        , 0,  0.5   * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS * -0.75, 0,  0.625 * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS * -0.5 , 0,  0.75  * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS * -0.25, 0,  0.875 * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(                               0, 0,          HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS *  0.25, 0,  0.875 * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS *  0.5 , 0,  0.75  * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	pts.append(Vector3(  HexHelper.INNER_RADIUS *  0.75, 0,  0.625 * HexHelper.OUTER_RADIUS) * HexHelper.SOLID_OUTER_GEOMETRY_RADIUS)
	
	
	for i in range(len(pts)):
		pts[i] += coord_offset + Vector3.UP * hex_position.pos.y
		
		var pt = Vector2(pts[i].x, pts[i].z)
		var local_norm_uv = (pt + uv_offset) / uv_ratio
		var new_uv = local_norm_uv
		uvs.append(new_uv)
		
		water_data.append(0.0)
		water_data.append(0.0)
	
	var idx : Array[int] = []
	
	#generate indexing for inner hexagon geometry
	for i in range(1, 13):
		idx.append(idx_offset)
		if i + 1 < 13:
			idx.append(idx_offset + (i + 1))
		else:
			idx.append(idx_offset + 1)
		idx.append(idx_offset + i)
	
	
	#indexing of outer hexagon ring
	var inner_offset = idx_offset + 1
	var outer_offset = idx_offset + 13
	for i in range(13, len(pts)):
		outside_indices.append(idx_offset + i)
	for i in range(6):
		idx.append(outer_offset + i * 4)
		idx.append(inner_offset + i * 2)
		idx.append(outer_offset + i * 4 + 1)
		
		idx.append(outer_offset + i * 4 + 1)
		idx.append(inner_offset + i * 2)
		idx.append(inner_offset + i * 2 + 1)
		
		idx.append(outer_offset + i * 4 + 1)
		idx.append(inner_offset + i * 2 + 1)
		idx.append(outer_offset + i * 4 + 2)
		
		idx.append(outer_offset + i * 4 + 2)
		idx.append(inner_offset + i * 2 + 1)
		idx.append(outer_offset + i * 4 + 3)
		
		idx.append(outer_offset + i * 4 + 3)
		idx.append(inner_offset + i * 2 + 1)
		idx.append(inner_offset + ((i + 1) % 6) * 2)
		
		idx.append(outer_offset + i * 4 + 3)
		idx.append(inner_offset + ((i + 1) % 6) * 2)
		idx.append(outer_offset + ((i + 1) % 6) * 4)
	
	return [pts, idx, uvs, water_data]

func update_tile_height():
	pass
func update_custom_props(arrays):
	if water_node.content.water == 0:
		return
	var water_val = water_node.content.water / water_node.max_node_content
	var pol_val = water_node.content.volume_of("POLLUTION") / water_node.max_node_content
	if water_val == last_water and pol_val == last_pol:
		return 
	last_water = water_val
	last_pol = pol_val
	for i in range(index_offset, index_offset + vertex_count):
		arrays[Mesh.ARRAY_CUSTOM0].set(i * 2, water_val)
		arrays[Mesh.ARRAY_CUSTOM0].set(i * 2 + 1, pol_val)
	pass
func update_river_vertices():
	pass
