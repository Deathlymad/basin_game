extends Node

class_name WaterGraph


var nodes : Array[WaterNode]

func add_node(node:WaterNode):
	nodes.append(node)

func update():
	for n in nodes:
		n.update()

class FluidMix:
	var water : float
	var additions : Dictionary[String, float] #TODO make this a sort of enum
	
	var volume : float : 
		get():
			var s = water
			for v in additions.values():
				s += v
			return s
	
	func _init(_water : float = 0.0, adds : Dictionary[String, float] = {}):
		water = _water
		additions = adds
	
	func volume_of(a:String):
		if a in additions.keys():
			return additions[a]
		return 0
	
	func subset(array:Array[String]):
		var dict : Dictionary[String, float] = {}
		
		for k in additions.keys():
			if k in array:
				dict[k] = additions[k]
		return FluidMix.new(water, dict)
	
	func scalar(val : float):
		var dict : Dictionary[String, float] = {}
		
		for k in additions.keys():
			dict[k] = additions[k] * val
		
		return FluidMix.new(water * val, dict)
	
	#inline add
	func merge(other : FluidMix):
		water += other.water
		for k in other.additions.keys():
			if not k in additions.keys():
				additions[k] = 0
			
			additions[k] += other.additions[k]
	
	#copy difference
	func minus(other : FluidMix):
		
		var dict : Dictionary[String, float] = {}
		
		for k in additions.keys():
			dict[k] = additions[k]
			if k in other.additions.keys():
				dict[k] -= other.additions[k]
		
		return FluidMix.new(water - other.water, dict)
	
#TODO order this structure

class WaterConnection:
	var source : WaterNode
	var dest : WaterNode
	var max_flow : float = 10
	
	func get_max_flow():
		return min(max_flow, max(0, (source.content.volume - dest.content.volume) / 1.2))
	
	func get_flow_amount(flow:float):
		return source.content.scalar(min(flow, get_max_flow() / max_flow))
	
	func get_effective_dest_volume():
		return dest.content.volume

class FilteredWaterConnection extends WaterConnection:
	#whitelist filter
	var allowed_fluids : Array[String] = []
	
	func get_max_flow():
		#the following restrictions apply:
		# - no more volume can flow than the connection permits
		# - no more volume can flow than exist in the node
		# - negative flow is illegal
		# - the flow is the delta of the source volume and the destination volume
		return min(max_flow, source.volume_of(allowed_fluids), max(0, (source.volume - dest.volume_of(allowed_fluids)) / 2))
	func get_flow_amount(flow:float):
		return source.content.subset(allowed_fluids).scalar(min(flow, get_max_flow() / max_flow))
class WaterPumpConnection extends FilteredWaterConnection:
	func get_max_flow():
		#pump desinations accept as much water as they can absorb
		return (dest.max_node_content - dest.content.volume)
class WaterRunoffConnection extends WaterConnection:
	var height_difference :float = 0
	
	func _init(difference : float):
		height_difference = difference
	
	func get_max_flow():
		return min(max_flow, max(0, (source.content.volume - (dest.content.volume - height_difference)) / 2))
	
	func get_effective_dest_volume():
		return max(0, dest.content.volume - height_difference)

class WaterNode:
	var max_node_content = 10
	var pos : HexHelper.HexCoordinate
	var content : FluidMix
	var should_evaporate : bool = true
	
	var sources : Array[WaterConnection]
	var destinations : Array[WaterConnection]
	
	func _init(position : HexHelper.HexCoordinate):
		pos = position
		content = FluidMix.new()
		sources = []
		destinations = []
	
	func add_water(amt : float):
		if content.volume + amt < max_node_content:
			content.water += amt
		else:
			content.water = max_node_content
	
	func update():
		
		if content.water == 0:
			return
		
		#push logic
		var flow_sum = 0
		var min_neighbor = 0
		for dest in destinations:
			flow_sum += dest.get_max_flow()
			min_neighbor = min(min_neighbor, dest.get_effective_dest_volume())
		flow_sum = min(flow_sum, content.volume)
		if flow_sum > 0:
			var flow_usage = min(1.0, (content.volume - min_neighbor) / flow_sum)
			
			for dest in destinations:
				var transfer = dest.get_flow_amount(flow_usage)
				content = content.minus(transfer)
				dest.dest.content.merge(transfer)
		
			if flow_usage == 1.0 and should_evaporate:
				#evaporation
				content.water /= 1.1
		if content.water < 0.1:
			content.water = 0
	
	func add_source_neighbor(connection : WaterConnection, propagate : bool = true):
		if connection.dest != self:
			print("illegal source connection addition")
			return
		if sources.find_custom(func (o):return o.source == connection.source and o.get_class() == connection.get_class()) == -1:
			sources.append(connection)
			if propagate:
				connection.source.add_destination_neighbor(connection, false)
		else:
			print("duplicate connection")
	func add_destination_neighbor(connection : WaterConnection, propagate : bool = true):
		if connection.source != self:
			print("illegal destination connection addition")
			return
		if destinations.find_custom(func (o): return o.dest == connection.dest and o.get_class() == connection.get_class()) == -1:
			destinations.append(connection)
			if propagate:
				connection.dest.add_source_neighbor(connection, false)
		else:
			print("duplicate connection")
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
