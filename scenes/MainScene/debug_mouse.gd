extends Node3D

var last_hex_coord = null

func _input(evt : InputEvent):
	if evt is InputEventMouseMotion:
		var ray_start = $Node3D/Camera3D.project_ray_origin(evt.position)
		var ray_end = ray_start + $Node3D/Camera3D.project_ray_normal(evt.position) * 1000
		var world3d : World3D = get_world_3d()
		var space_state = world3d.direct_space_state
		
		if space_state == null:
			return
		
		var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
		query.collide_with_areas = true
		
		var res = space_state.intersect_ray(query)
		if "position" in res:
			var coord = HexHelper.HexCoordinate.from_carthesian(res["position"])
			coord.round_coord()
			last_hex_coord = coord.duplicate()
			$CanvasLayer/PositionDisplay.text = coord.to_string()
			var hex = $Basin.get_hexagon_from_hex_coord(coord)
			if hex:
				$CanvasLayer/WaterDisplay.text = str(hex.water_node.water_amt)
				$CanvasLayer/PollutionDisplay.text = str(hex.water_node.pollution_amt)
			else:
				$CanvasLayer/WaterDisplay.text = "-"
				$CanvasLayer/PollutionDisplay.text = "-"
			$DebugDot.position = res["position"]
	elif evt is InputEventKey:
		if evt.is_action("debug_rain"):
			
			var hex = $Basin.get_hexagon_from_hex_coord(last_hex_coord)
			if hex:
				hex.water_node.add_water(5)
				$CanvasLayer/WaterDisplay.text = str(hex.water_node.water_amt)
		elif evt.is_action("debug_tick"):
			var hex = $Basin.get_hexagon_from_hex_coord(last_hex_coord)
			if hex:
				hex.spawn_pump()
	
