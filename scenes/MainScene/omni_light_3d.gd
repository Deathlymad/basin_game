extends Node3D

func _process(_delta):
	
	rotation.y = float(Time.get_ticks_msec()) /300
	
