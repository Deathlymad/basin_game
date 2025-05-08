extends Node3D

@export var height : float

var hex_position : HexHelper.HexCoordinate



func _ready():
	var reconstructed = HexHelper.HexCoordinate.from_carthesian(hex_position.to_carthesian())
	#reconstructed.round_coord()
	#print(hex_position.to_string(), reconstructed.to_string())
	
	#$CanvasLayer/Label.text = hex_position.to_string()
	var uv =  $MeshInstance3D.uv_offset
	print(uv)
	$CanvasLayer/Label.text = str(uv)
	
	#pos update
	global_position = hex_position.to_carthesian() + Vector3.UP * height
	
