extends Node

class_name WaterGraph


var nodes : Array[WaterNode]

func add_node(node:WaterNode):
	nodes.append(node)

func update():
	for n in nodes:
		n.update()

class WaterConnection:
	var source : WaterNode
	var dest : WaterNode
	var flow : float = 1
	var weight : float #factor that determines the maximum ratio between destination and source
	var weight_offset : float #factor that determines the maximum offset between destination and source

class WaterNode:
	var max_node_content = 10
	var pos : HexHelper.HexCoordinate
	var water_amt : float
	var pollution_amt : float
	var should_evaporate : bool = true
	var volume : float :
		get():
			return water_amt + pollution_amt
	
	var sources : Array[WaterConnection]
	var destinations : Array[WaterConnection]
	
	func _init(position : HexHelper.HexCoordinate):
		pos = position
		water_amt = 0
		pollution_amt = 0
		sources = []
		destinations = []
	
	func add_water(amt : float):
		if volume + amt < max_node_content:
			water_amt += amt
		else:
			water_amt = max_node_content
	func add_pollution(amt : float):
		if volume + amt < max_node_content:
			water_amt += amt
		else:
			water_amt = max_node_content
	
	func update():
		
		if water_amt == 0:
			return
		
		#push logic
		var flow_sum = 0
		for dest in destinations:
			var transfer = (volume - (dest.dest.volume * dest.weight - dest.weight_offset)) / 2
			flow_sum += min(dest.flow, transfer)
		var flow_usage = min(flow_sum, volume) / flow_sum
		var last_water_amt = water_amt
		for dest in destinations:
			var transfer = (volume -(dest.dest.volume * dest.weight - dest.weight_offset)) / 2
			water_amt = max(0, water_amt)
			dest.dest.water_amt += min(dest.flow * flow_usage, transfer, water_amt)
			water_amt -= min(dest.flow * flow_usage, transfer, water_amt)
			pollution_amt = max(0, pollution_amt)
			if pollution_amt > 0:
				dest.dest.pollution_amt += min(dest.flow * flow_usage, transfer, pollution_amt)
				pollution_amt -= min(dest.flow * flow_usage, transfer, pollution_amt)
		
		if last_water_amt >= water_amt and should_evaporate:
			#evaporation
			water_amt /= 1.1
		if water_amt < 0.2:
			water_amt = 0
	
	func add_source_neighbor(other : WaterNode, flow : float = 1, weight : float = 1, weight_off : float = 1):
		if destinations.find_custom(func (o):return o.dest == self and o.source == other) == -1:
			var v = WaterConnection.new()
			v.source = other 
			v.dest = self
			v.flow = flow
			v.weight = weight
			v.weight_offset = weight_off
			sources.append(v)
			other.destinations.append(v)
	func add_destination_neighbor(other : WaterNode, flow : float = 1, weight : float = 1, weight_off : float = 1):
		if destinations.find_custom(func (o): return o.source == self and o.dest == other) == -1:
			var v = WaterConnection.new()
			v.source = self
			v.dest = other
			v.flow = flow
			v.weight = weight
			v.weight_offset = weight_off
			destinations.append(v)
			other.sources.append(v)
	func remove_source_neighbor(other : WaterNode, propagate : bool = true):
		var search = destinations.find_custom(func (o): return o.dest == self and o.source == other)
		if search != -1:
			sources.remove_at(search)
			if propagate:
				other.remove_destination_neighbor(self, false)
	func remove_destination_neighbor(other : WaterNode, propagate : bool = true):
		var search = destinations.find_custom(func (o): return o.dest == other and o.source == self)
		if search != -1:
			destinations.remove_at(search)
			if propagate:
				other.remove_source_neighbor(self, false)
