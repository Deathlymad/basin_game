extends Node3D

@export var hex_pos_proxy : Vector3
@export var height : float

var hex_position : HexHelper.HexCoordinate
func _ready():
	hex_position = HexHelper.HexCoordinate.new(hex_pos_proxy.x, hex_pos_proxy.y, hex_pos_proxy.z)
	$CanvasLayer/Label.text = hex_position.to_coord_string()
	
	#pos update
	global_position = hex_position.to_carthesian() + Vector3.UP * height
