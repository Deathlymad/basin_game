extends Node

var auqeduct_for_connection_bitset = {
	1 : { "obj" : load("res://assets/models/NODE_1.obj"),"rot" : 300	},
	2 :  {"obj" : load("res://assets/models/NODE_1.obj"), "rot" : 0	},
	3 :  {"obj" : load("res://assets/models/NODE_2_TIGHT.obj"), "rot" : 0	},
	4 :  {"obj" : load("res://assets/models/NODE_1.obj"), "rot" : 60 },
	5 :  {"obj" : load("res://assets/models/NODE_2_BEND.obj"), "rot" : 60 },
	6 :  {"obj" : load("res://assets/models/NODE_2_TIGHT.obj"), "rot" : 60	},
	
	
	
	8 :  {"obj" : load("res://assets/models/NODE_1.obj"), "rot" : 120 },
	9 : {"obj" : load("res://assets/models/NODE_2_STRAIGHT.obj"), "rot" : 120 },
	10 :  {"obj" : load("res://assets/models/NODE_2_BEND.obj"), "rot" : 120 },
	11 :  {"obj" : load("res://assets/models/NODE_3_y.obj"), "rot" : 120 },
	12 :  {"obj" : load("res://assets/models/NODE_2_TIGHT.obj"), "rot" : 120 },
	
	13 :  {"obj" : load("res://assets/models/NODE_3_y_FLIP.obj"), "rot" : 60 }, 
	

	7 :  {"obj" : load("res://assets/models/NODE_3_SIDE.obj"), "rot" : 300	},
	28 :  {"obj" : load("res://assets/models/NODE_3_SIDE.obj"), "rot" : 240	},
	41 :  {"obj" : load("res://assets/models/NODE_3_SIDE.obj"), "rot" : 300	},
	49 :  {"obj" : load("res://assets/models/NODE_3_SIDE.obj"), "rot" : 0	},
	
	14 :  {"obj" : load("res://assets/models/NODE_3_SIDE.obj"), "rot" : 0	},
	56 :  {"obj" : load("res://assets/models/NODE_3_SIDE.obj"), "rot" : 120 },
	35 :  {"obj" : load("res://assets/models/NODE_3_SIDE.obj"), "rot" : 240	},
	
	15 : {"obj" : load("res://assets/models/NODE_4_SIDE.obj"), "rot" : 300 },
	16 : {"obj" : load("res://assets/models/NODE_1.obj"), "rot" : 180},
	17 : {"obj" : load("res://assets/models/NODE_2_BEND.obj"), "rot" : 300 },
	18 : {"obj" : load("res://assets/models/NODE_2_STRAIGHT.obj"), "rot" : 0 },
	
	19 : {"obj" : load("res://assets/models/NODE_3_y_FLIP.obj"), "rot" : 0 }, # 19 is missing same as 13
	
	20 : {"obj" : load("res://assets/models/NODE_2_BEND.obj"), "rot" : 180 },
	21 : {"obj" : load("res://assets/models/NODE_3_FORK.obj"), "rot" : 60 },
	22 : {"obj" : load("res://assets/models/NODE_3_y.obj"), "rot" : 180 },
	23 : {"obj" : load("res://assets/models/NODE_4_FORK.obj"), "rot" : 180 },
	24 : {"obj" : load("res://assets/models/NODE_2_TIGHT.obj"), "rot" : 180 },
	25 : {"obj" : load("res://assets/models/NODE_3_y.obj"), "rot" : 300 },
	
	26 : {"obj" : load("res://assets/models/NODE_3_y_FLIP.obj"), "rot" : 120 }, # 19 is missing same as 13
	
	27 : {"obj" : load("res://assets/models/NODE_4_X.obj"), "rot" : 120 },
	
	
	
	29 : {"obj" : load("res://assets/models/NODE_4_FORK.obj"), "rot" : 300 },
	30 : {"obj" : load("res://assets/models/NODE_4_SIDE.obj"), "rot" : 0 },
	31 : {"obj" : load("res://assets/models/NODE_5.obj"), "rot" : 300 },
	32 : {"obj" : load("res://assets/models/NODE_1.obj"), "rot" : 240},
	33 : {"obj" : load("res://assets/models/NODE_2_TIGHT.obj"), "rot" : 300},
	34 : {"obj" : load("res://assets/models/NODE_2_BEND.obj"), "rot" : 0},
	
	
	
	36 : {"obj" : load("res://assets/models/NODE_2_STRAIGHT.obj"), "rot" : 60 },
	37 : {"obj" : load("res://assets/models/NODE_3_y.obj"), "rot" : 60 },
	
	38 :  {"obj" : load("res://assets/models/NODE_3_y_FLIP.obj"), "rot" : 180 }, 
	
	39:{"obj" : load("res://assets/models/NODE_4_SIDE.obj"), "rot" : 240 },
	40 : {"obj" : load("res://assets/models/NODE_2_BEND.obj"), "rot" : 240},
	
	
	
	42 : {"obj" : load("res://assets/models/NODE_3_FORK.obj"), "rot" : 0 },
	43: {"obj" : load("res://assets/models/NODE_4_FORK.obj"), "rot" : 120 },
	44 : {"obj" : load("res://assets/models/NODE_3_y.obj"), "rot" : 240 },
	45 : {"obj" : load("res://assets/models/NODE_4_X.obj"), "rot" : 240 },
	46 : {"obj" : load("res://assets/models/NODE_4_FORK.obj"), "rot" : 240 },
	47 : {"obj" : load("res://assets/models/NODE_5.obj"), "rot" : 240 },
	48 : {"obj" : load("res://assets/models/NODE_2_TIGHT.obj"), "rot" : 240 },
	
	
	
	50 :  {"obj" : load("res://assets/models/NODE_3_y_FLIP.obj"), "rot" : 240 }, 
	
	51 : {"obj" : load("res://assets/models/NODE_4_SIDE.obj"), "rot" : 180 },
	
	52 :  {"obj" : load("res://assets/models/NODE_3_y_FLIP.obj"), "rot" : 300 }, 
	
	53 : {"obj" : load("res://assets/models/NODE_4_FORK.obj"), "rot" : 60 },
	54 : {"obj" : load("res://assets/models/NODE_4_X.obj"), "rot" : 0 },
	55 : {"obj" : load("res://assets/models/NODE_5.obj"), "rot" : 180 },
	
	
	
	57 : {"obj" : load("res://assets/models/NODE_4_SIDE.obj"), "rot" : 120 },
	58: {"obj" : load("res://assets/models/NODE_4_FORK.obj"), "rot" : 0 },
	59 : {"obj" : load("res://assets/models/NODE_5.obj"), "rot" : 120 },
	60 : {"obj" : load("res://assets/models/NODE_4_SIDE.obj"), "rot" : 60 },
	61 : {"obj" : load("res://assets/models/NODE_5.obj"), "rot" : 60 },
	62 : {"obj" : load("res://assets/models/NODE_5.obj"), "rot" : 0 },
	63: {
		"obj" : load("res://assets/models/NODE_6.obj"),
		"rot" : 0
	}
}
