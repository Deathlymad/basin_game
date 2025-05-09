extends Node3D

func _process(delta):
	
	rotation.y = float(Time.get_ticks_msec()) /300
	
