extends Node3D

@export var hexgrid_radius : int

func _tree_entered():
	for child in get_children():
		child.size = hexgrid_radius
