extends Node3D

var start_pos : HexHelper.HexCoordinate = null
var aqueduct_scene = preload("res://scenes/Aqueduct/Aqueduct.tscn")
var temp_aqueducts = []


var last_hex = null

func hex_raycast(pos : Vector2):
		var ray_start = $"../Node3D/Camera3D".project_ray_origin(pos)
		var ray_end = ray_start + $"../Node3D/Camera3D".project_ray_normal(pos) * 1000
		var world3d : World3D = get_world_3d()
		var space_state = world3d.direct_space_state
		
		if space_state == null:
			return {}
		
		var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
		query.collide_with_areas = true
		
		return space_state.intersect_ray(query)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed == true and event.button_index == MOUSE_BUTTON_LEFT:
			var res = hex_raycast(event.position)
			if "position" in res:
				start_pos = HexHelper.HexCoordinate.from_carthesian(res["position"])
				start_pos.round_coord()
		else:
			var res = hex_raycast(event.position)
			if "position" in res:
				place()
			start_pos = null
	if event is InputEventMouseMotion and start_pos:
		var res = hex_raycast(event.position)
		if "position" in res:
			var p = HexHelper.HexCoordinate.from_carthesian(res["position"])
			p.round_coord()
			if last_hex and p !=last_hex:
				update_aqueduct_structure(p)
				last_hex = p
			elif not last_hex:
				last_hex = p

func update_aqueduct_structure(target : HexHelper.HexCoordinate):
	for a in temp_aqueducts:
		if a[0]:
			remove_child(a[0])
			a[0].queue_free()
	temp_aqueducts.clear()
	var path = $"../Basin".compute_path(start_pos, target)
	for i in range(1, len(path)):
		var p = aqueduct_scene.instantiate()
		p.position = path[i - 1].to_carthesian() + Vector3.UP * path[i - 1].distance_to(HexHelper.HexCoordinate.new(0,0,0))
		var dir = path[i - 1].duplicate().minus(path[i]).get_direction()
		if dir == null:
			dir = HexHelper.get_opposite_hex_direction(path[i].duplicate().minus(path[i - 1]).get_direction())
		if dir != null:
			p.rotation_degrees.y = HexHelper.get_opposite_hex_direction(dir) * 60 - 60
			temp_aqueducts.append([p, null])
			add_child(p)
		else:
			pass
		p = aqueduct_scene.instantiate()
		p.position = path[i].to_carthesian() + Vector3.UP * path[i].distance_to(HexHelper.HexCoordinate.new(0,0,0))
		if dir != null:
			p.rotation_degrees.y = dir * 60 - 60
			temp_aqueducts.append([p, path[i], HexHelper.get_prev_hex_direction(dir)])
			add_child(p)
		else:
			pass
	
func place():
	for t in temp_aqueducts:
		remove_child(t[0])
		t[0].queue_free()
		if t[1] != null:
			$"../Basin".get_hexagon_from_hex_coord(t[1]).add_aqueduct_in_for_height(5, t[2])
	temp_aqueducts.clear()
