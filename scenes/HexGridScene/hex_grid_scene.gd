extends Node3D

var hexagons : Array[Hexagon]
var size : int
@export var direction : HexHelper.HexDirection

var uv_ratio : Vector2

func _calculate_global_uv_ratio():
	
	var extremes : Array[Vector3]
	
	extremes.append(HexHelper.HexCoordinate.new(0,0,size).to_carthesian())
	extremes.append(HexHelper.HexCoordinate.new(size,0,0).to_carthesian())
	extremes.append(HexHelper.HexCoordinate.new(0,0,-size).to_carthesian())
	extremes.append(HexHelper.HexCoordinate.new(-size,0,0).to_carthesian())
	
	var min = Vector2.ZERO
	var max = Vector2.ZERO
	
	for pt in extremes:
		min.x = min(pt.x, min.x)
		min.y = min(pt.z, min.y)
		max.x = max(pt.x, max.y)
		max.y = max(pt.z, max.y)
	
	uv_ratio = max - min + Vector2(12, 12)
	
func _ready():
	hexagons = []
	var start_pos = HexHelper.HexCoordinate.new(0, 0, 0)
	var next_dir = HexHelper.get_next_hex_direction(direction)
	start_pos = start_pos.step_in_dir(direction)
	
	for i in range(size):
		var hex = Hexagon.new()
		hex.set_hex_position(start_pos.duplicate())
		hex.height = hex.get_hex_position().distance_to(HexHelper.HexCoordinate.new(0,0,0))
		if(i > 0):
			hex.add_neighbor(hexagons[len(hexagons) - (size - i - 1) - 1])
			hex.add_neighbor(hexagons[len(hexagons) - (size - i - 1) - 2])
		hexagons.append(hex)
		hex.position = hex.get_hex_position().to_carthesian() + Vector3.UP * hex.height
		add_child(hex)
		var step_pos = start_pos.duplicate()
		start_pos.step_in_dir(direction)
		step_pos.step_in_dir(next_dir)
		var last_minor_hex = hex
		for j in range(size - i - 1):
			hex = Hexagon.new()
			hex.set_hex_position(step_pos.duplicate())
			hex.height = hex.get_hex_position().distance_to(HexHelper.HexCoordinate.new(0,0,0))
			hex.add_neighbor(hexagons[len(hexagons) - 1])
			if(i > 0):
				hex.add_neighbor(hexagons[len(hexagons) - (size - i - 1) - 1])
				hex.add_neighbor(hexagons[len(hexagons) - (size - i - 1) - 2])
			last_minor_hex = hex
			hexagons.append(hex)
			hex.position = hex.get_hex_position().to_carthesian() + Vector3.UP * hex.height
			add_child(hex)
			step_pos.step_in_dir(next_dir)
	
	generate_mesh()

func contains(coord : HexHelper.HexCoordinate) -> bool:
	#TODO this can be solved in constant time with coordinate calculation of chunk extremes
	for h in hexagons:
		if coord.matches(h.get_hex_position()):
			return true
	return false
func get_hexagon(coord : HexHelper.HexCoordinate) -> Hexagon:
	for h in hexagons:
		if coord.matches(h.get_hex_position()):
			return h
	return null

func build_chunk_neighborhood():
	var origin = HexHelper.HexCoordinate.new(0, 0, 0)
	var start_pos = HexHelper.HexCoordinate.new(0, 0, 0)
	start_pos = start_pos.step_in_dir(HexHelper.get_prev_hex_direction(direction))
	
	var uv_offset = Vector2(global_position.x, global_position.z)
	
	var pos = start_pos.duplicate()
	var off = 0
	var last_off = -1
	for j in range(size):
		var h = get_parent().get_hexagon_from_hex_coord(pos)
		if last_off > -1:
			hexagons[last_off].add_neighbor(h)
		hexagons[off].add_neighbor(h)
		last_off = off
		off += size - j
		pos.step_in_dir(direction)

#Rendering Code

func add_hexagons_to_geometry(arrays):
	for hex in hexagons:
		var glob_pos = global_position + HexHelper.HexCoordinate.new(-1,0,-size - 1).to_carthesian()
		var res = hex._update_mesh(uv_ratio, Vector2(glob_pos.x, glob_pos.z), hex.get_hex_position().to_carthesian(), arrays[Mesh.ARRAY_VERTEX].size())
		arrays[Mesh.ARRAY_VERTEX].append_array(res[0])
		arrays[Mesh.ARRAY_INDEX].append_array(res[1])
		arrays[Mesh.ARRAY_TEX_UV].append_array(res[2])
	
func add_connectors_to_grid(arrays):
	for h in hexagons:
		for n in [HexHelper.HexDirection.NE, HexHelper.HexDirection.E, HexHelper.HexDirection.SE]:
			var o = h.get_neighbor_in_dir(n)
			if o != null and o in hexagons:
				#I can probably inline this, but i am lazy and don't understand my own helper functions anymore
				if n == HexHelper.HexDirection.NE:
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 3)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 4)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 1)
					
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 4)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 6)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 1)
				elif n == HexHelper.HexDirection.E:
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 4)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 5)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 1)
					
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 2)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 4)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 1)
				elif n == HexHelper.HexDirection.SE:
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 5)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 6)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 2)
					
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 5)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 2)
					arrays[Mesh.ARRAY_INDEX].append(hexagons.find(o) * 7 + 3)
	
func generate_triangles(arrays):
	for h in hexagons:
		var a = h.get_neighbor_in_dir(HexHelper.HexDirection.NE)
		var b = h.get_neighbor_in_dir(HexHelper.HexDirection.E)
		var c = h.get_neighbor_in_dir(HexHelper.HexDirection.SE)
		
		if b == null or not b in hexagons:
			continue
		
		if a != null and a in hexagons:
			arrays[Mesh.ARRAY_INDEX].append(hexagons.find(b) * 7 + 2)
			arrays[Mesh.ARRAY_INDEX].append(hexagons.find(a) * 7 + 6)
			arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 4)
		if c != null and c in hexagons:
			arrays[Mesh.ARRAY_INDEX].append(hexagons.find(c) * 7 + 3)
			arrays[Mesh.ARRAY_INDEX].append(hexagons.find(b) * 7 + 1)
			arrays[Mesh.ARRAY_INDEX].append(hexagons.find(h) * 7 + 5)
	
#THIS IS A FUCKING UGLY PIECE OF CODE BUT AT THIS POINT I CAN'T DEAL WITH DIRECTIONS ANYMORE
#ALSO APPARENTLY NORTH IS DIRECTED TO CAMERA??? IDEK ANYMORE
func generate_chunk_border_in_dir(arrays, d:HexHelper.HexDirection):
	var origin = HexHelper.HexCoordinate.new(0, 0, 0)
	var start_pos = HexHelper.HexCoordinate.new(0, 0, 0)
	start_pos = start_pos.step_in_dir(d)
	var dir = HexHelper.get_next_hex_direction(d)
	
	var glob_pos = global_position + HexHelper.HexCoordinate.new(-1,0,-size - 1).to_carthesian()
	var uv_offset = Vector2(glob_pos.x, glob_pos.z)
	
	var pos = start_pos.duplicate()
	var off = 0
	var last_off = 0
	for j in range(size):
		if dir == HexHelper.HexDirection.E:
			arrays[Mesh.ARRAY_INDEX].append(5 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(6 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 1)
			arrays[Mesh.ARRAY_INDEX].append(5 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 1)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
			
			
			if j > 0:
				arrays[Mesh.ARRAY_INDEX].append(6 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(1 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				arrays[Mesh.ARRAY_INDEX].append(1 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				
				
				arrays[Mesh.ARRAY_INDEX].append(1 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(5 + off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
				
				arrays[Mesh.ARRAY_INDEX].append(6 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				if j == 1:
					arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) - 1) #smaller array, could be resolved with smarter buffer layout
				else:
					arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) - 2)
				
			last_off = off
			off += size - j
			
			arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() + Vector3( 0, pos.distance_to(origin), -HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() + Vector3( HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, pos.distance_to(origin), -0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			
			if j > 0:
				arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() +  Vector3( -HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, pos.distance_to(origin), -0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			
			arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( 0, 0,-HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0,-0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			if j > 0:
				arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( -HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0,-0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			
		elif dir == HexHelper.HexDirection.SE:
			arrays[Mesh.ARRAY_INDEX].append(6 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(1 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 1)
			arrays[Mesh.ARRAY_INDEX].append(6 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 1)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
			
			
			if j > 0:
				arrays[Mesh.ARRAY_INDEX].append(1 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(2 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				arrays[Mesh.ARRAY_INDEX].append(2 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				
				
				arrays[Mesh.ARRAY_INDEX].append(2 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(6 + off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
				
				arrays[Mesh.ARRAY_INDEX].append(1 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				if j == 1:
					arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) - 1) #smaller array, could be resolved with smarter buffer layout
				else:
					arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) - 2)
				
			last_off = off
			off += size - j
			
			arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() + Vector3(  -HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, pos.distance_to(origin), -0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() + Vector3( 0, pos.distance_to(origin),       -HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			
			if j > 0:
				arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() +  Vector3(-HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS,pos.distance_to(origin),  0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			
			arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( -HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0,-0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( 0, 0,-HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			if j > 0:
				arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( -HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0,0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			
		elif dir == HexHelper.HexDirection.SW:
			arrays[Mesh.ARRAY_INDEX].append(1 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(2 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 1)
			arrays[Mesh.ARRAY_INDEX].append(1 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 1)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
			
			
			if j > 0:
				arrays[Mesh.ARRAY_INDEX].append(2 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(3 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				arrays[Mesh.ARRAY_INDEX].append(3 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				
				
				arrays[Mesh.ARRAY_INDEX].append(3 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(1 + off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
				
				arrays[Mesh.ARRAY_INDEX].append(2 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				if j == 1:
					arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) - 1) #smaller array, could be resolved with smarter buffer layout
				else:
					arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) - 2)
				
			last_off = off
			off += size - j
			
			arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() + Vector3(-HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, pos.distance_to(origin),  0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() + Vector3(-HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, pos.distance_to(origin), -0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			
			if j > 0:
				arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() +  Vector3(0, pos.distance_to(origin),        HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			
			arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( -HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0,0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( -HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0,-0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			if j > 0:
				arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( 0, 0,HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			
		elif dir == HexHelper.HexDirection.W:
			arrays[Mesh.ARRAY_INDEX].append(2 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(3 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 1)
			arrays[Mesh.ARRAY_INDEX].append(2 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 1)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
			
			
			if j > 0:
				arrays[Mesh.ARRAY_INDEX].append(3 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(4 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				arrays[Mesh.ARRAY_INDEX].append(4 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				
				
				arrays[Mesh.ARRAY_INDEX].append(4 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(2 + off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
				
				arrays[Mesh.ARRAY_INDEX].append(3 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				if j == 1:
					arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) - 1) #smaller array, could be resolved with smarter buffer layout
				else:
					arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) - 2)
				
			last_off = off
			off += size - j
			
			arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() +  Vector3( 0, pos.distance_to(origin), HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() + Vector3( -HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, pos.distance_to(origin), 0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			
			if j > 0:
				arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() +  Vector3( HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, pos.distance_to(origin), 0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			
			arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( 0, 0,HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( -HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0,0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			if j > 0:
				arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0,0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			
		elif dir == HexHelper.HexDirection.NE:
			arrays[Mesh.ARRAY_INDEX].append(4 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(5 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 1)
			arrays[Mesh.ARRAY_INDEX].append(4 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 1)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
			
			if j > 0:
				arrays[Mesh.ARRAY_INDEX].append(5 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(6 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				arrays[Mesh.ARRAY_INDEX].append(6 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				
				
				arrays[Mesh.ARRAY_INDEX].append(6 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(4 + off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
				
				arrays[Mesh.ARRAY_INDEX].append(5 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				if j == 1:
					arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) - 1) #smaller array, could be resolved with smarter buffer layout
				else:
					arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) - 2)
				
			last_off = off
			off += size - j
			
			arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() + Vector3(HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, pos.distance_to(origin), -0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() + Vector3(HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, pos.distance_to(origin), 0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			
			if j > 0:
				arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() +  Vector3(0, pos.distance_to(origin), -HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			
			arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0,-0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0,0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			if j > 0:
				arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( 0, 0,-HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			
		elif dir == HexHelper.HexDirection.NW:
			arrays[Mesh.ARRAY_INDEX].append(3 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(4 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 1)
			arrays[Mesh.ARRAY_INDEX].append(3 + off * 7)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 1)
			arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
			
			if j > 0:
				arrays[Mesh.ARRAY_INDEX].append(4 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(5 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				arrays[Mesh.ARRAY_INDEX].append(5 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				
				
				arrays[Mesh.ARRAY_INDEX].append(5 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(3 + off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]))
				
				arrays[Mesh.ARRAY_INDEX].append(4 + last_off * 7)
				arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) + 2)
				if j == 1:
					arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) - 1) #smaller array, could be resolved with smarter buffer layout
				else:
					arrays[Mesh.ARRAY_INDEX].append(len(arrays[Mesh.ARRAY_VERTEX]) - 2)
				
			last_off = off
			off += size - j
			
			arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() + Vector3(  HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, pos.distance_to(origin), 0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() + Vector3( 0, pos.distance_to(origin),       HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			
			if j > 0:
				arrays[Mesh.ARRAY_VERTEX].append(pos.to_carthesian() +  Vector3(HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, pos.distance_to(origin), -0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS))
			
			arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0,0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( 0, 0,HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			if j > 0:
				arrays[Mesh.ARRAY_TEX_UV].append((HexHelper.to_xz(pos.to_carthesian() + Vector3( HexHelper.INNER_RADIUS * HexHelper.SOLID_RADIUS, 0,-0.5 * HexHelper.OUTER_RADIUS * HexHelper.SOLID_RADIUS)) + uv_offset) / uv_ratio + (uv_ratio/2))
			
		pos.step_in_dir(dir)

func generate_mesh():
	_calculate_global_uv_ratio()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array()
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array()
	
	add_hexagons_to_geometry(arrays)
	add_connectors_to_grid(arrays)
	generate_triangles(arrays)
	generate_chunk_border_in_dir(arrays, HexHelper.get_prev_hex_direction(direction))
	# Create the Mesh.
	$MeshInstance3D.mesh = ArrayMesh.new()
	$MeshInstance3D.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	for c in $MeshInstance3D.get_children():
		$MeshInstance3D.remove_child(c)
	$MeshInstance3D.create_multiple_convex_collisions()
	
	var mdt = MeshDataTool.new()
	mdt.create_from_surface($MeshInstance3D.mesh, 0)
	for i in range(mdt.get_vertex_count()):
		var vert = mdt.get_vertex(i)
		mdt.set_vertex_normal(i, Vector3.ZERO)
		
	for i in range(mdt.get_face_count()):
		var facevert1 = mdt.get_face_vertex(i,0)
		var facevert2 = mdt.get_face_vertex(i,1)
		var facevert3 = mdt.get_face_vertex(i,2)
		
		var vert1 = mdt.get_vertex(facevert1)
		var vert2 = mdt.get_vertex(facevert2)
		var vert3 = mdt.get_vertex(facevert3)
		
		var normal = Plane(vert1, vert2, vert3).normal
		
		mdt.set_vertex_normal(facevert1, mdt.get_vertex_normal(facevert1) + normal)		
		mdt.set_vertex_normal(facevert2, mdt.get_vertex_normal(facevert2) + normal)
		mdt.set_vertex_normal(facevert3, mdt.get_vertex_normal(facevert3) + normal)
		
	for i in range(mdt.get_vertex_count()):
		var nor = mdt.get_vertex_normal(i)
		mdt.set_vertex_normal(i, nor.normalized())
	
	mdt.commit_to_surface($MeshInstance3D.mesh)
		
		
		
			
	
