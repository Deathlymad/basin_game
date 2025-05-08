extends Node3D

var hex_scene = preload("res://scenes/HexScene/HexScene.tscn")
@export var radius : int = 6

func _ready():
	var base_instance = HexHelper.HexCoordinate.ORIGIN;
	for x in range(-radius, radius):
		for z in range(-radius, radius):
			var hex_instance = hex_scene.instantiate()
			
			#hex_instance.height = ((abs(x)+abs(y)+abs(z))/3) - ((abs(x)+abs(y)+abs(z))/3)/2
			hex_instance.hex_position = HexHelper.HexCoordinate.new(x,0,z)
			hex_instance.height = hex_instance.hex_position.distance_to(base_instance)
			add_child(hex_instance)
				
