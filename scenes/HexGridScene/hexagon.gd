extends Node3D

class_name Hexagon

var height : float
var _hex_position : HexHelper.HexCoordinate
var neighbors : Array[Hexagon]

var debug_sphere

class AqueductNode:
	var water : WaterGraph.WaterNode
	var in_bits : int
	var out_bits : int
	var aque_model : MeshInstance3D
var nodes : Array[AqueductNode]
var aque_foundation : MeshInstance3D

enum AQUEDUCT_DIRECTION {
	NE =  1,
	E  =  2,
	SE =  4,
	SW =  8,
	W  = 16,
	NW = 32,
	GROUND = 64
}

var water_node : WaterGraph.WaterNode = WaterGraph.WaterNode.new(_hex_position)

func _ready():
	#var obj = MeshInstance3D.new()
	#obj.mesh = SphereMesh.new()
	#obj.material_override = StandardMaterial3D.new()
	#obj.material_override.albedo_color = Color(0, 64, 255)
	#obj.scale = Vector3.ZERO
	#add_child(obj)
	#debug_sphere = obj
	
	get_parent().get_parent().graph.add_node(water_node)
	
	for i in range(10):
		var o = AqueductNode.new()
		o.water = WaterGraph.WaterNode.new(get_hex_position())
		o.in_bits = 0
		o.out_bits = 0
		o.aque_model = MeshInstance3D.new()
		o.aque_model.scale = Vector3.ONE * 0.009
		o.aque_model.position.y = i - position.y + 5
		o.aque_model.material_override = StandardMaterial3D.new()
		o.aque_model.material_override.albedo_texture = load("res://assets/textures/wood.png")
		add_child(o.aque_model)
		nodes.append(o)

func add_aqueduct_in_for_height(height, in_dir, other_obj, out_dir):
	if nodes[height].out_bits == 0:
		nodes[height].out_bits |= 64
		nodes[height].water.add_destination_neighbor(water_node, 50, 0, 0)
	nodes[height].in_bits |= 1 << in_dir
	
	nodes[height].water.add_source_neighbor(other_obj.nodes[height].water, 5, 1, 0)
	
	if other_obj.nodes[height].out_bits & 63 == 0:
		other_obj.nodes[height].water.remove_destination_neighbor(water_node)
	
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
	aque_foundation.scale.y = (max_height * 2 - height) / 2
	aque_foundation.scale.z = 1
	aque_foundation.position.y = (max_height * 2 - height) / 2
	
	

#func _process(delta: float) -> void:
	#debug_sphere.scale = Vector3.ONE * water_node.water_amt / 2

func get_hex_position():
	return _hex_position
func set_hex_position(p):
	_hex_position = p

func add_neighbor(hex : Hexagon, propagate:bool = true):
	if not hex in neighbors:
		if propagate:
			hex.add_neighbor(self, false)
		neighbors.append(hex)
		
		if hex.height <= height:
			water_node.add_destination_neighbor(hex.water_node, 0.5, 1, (height - hex.height))
		if hex.height > height:
			water_node.add_source_neighbor(hex.water_node, 0.5, (hex.height - height))
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
		
	var normals : Array[Vector3] = []		
		
	var water_data = []
	for point in pts:
		water_data.append(0.0)
		water_data.append(0.0)
	
	return [pts, idx, uvs, water_data]
