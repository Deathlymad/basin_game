extends Node3D

@export var height : float

var hex_position : HexHelper.HexCoordinate

var HexRenderer = preload("res://scenes/HexScene/hexagon_renderer.gd")

func _ready():
	var reconstructed = HexHelper.HexCoordinate.from_carthesian(hex_position.to_carthesian())
	#reconstructed.round_coord()
	#print(hex_position.to_string(), reconstructed.to_string())
	
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = ArrayMesh.new()  # force a new mesh
	mesh_instance.set_script(HexRenderer)  # attach your renderer script
	add_child(mesh_instance)
	
	#$CanvasLayer/Label.text = hex_position.to_string()
	$CanvasLayer/Label.text = str(mesh_instance.uv_offset)
	
	#pos update
	global_position = hex_position.to_carthesian() + Vector3.UP * height
	
