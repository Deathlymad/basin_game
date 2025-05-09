extends Node

class WaterNode:
	var pos : HexHelper.HexCoordinate
	var water_amt : float
	var pollution_amt : float
	var volume : float :
		get():
			return water_amt + pollution_amt
	
	var sources : Array[WaterNode]
	var destinations : Array[WaterNode]
	
