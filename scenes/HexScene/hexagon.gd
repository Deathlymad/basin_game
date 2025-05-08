extends Node3D

@export var height : float

var hex_position : HexHelper.HexCoordinate



func _ready():
	$CanvasLayer/Label.text = hex_position.to_coord_string()
	
	#pos update
	global_position = hex_position.to_carthesian() + Vector3.UP * height
	
