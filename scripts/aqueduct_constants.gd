extends Node

var auqeduct_for_connection_bitset = {
	1 : { "obj" : load("res://assets/models/NODE_1.obj"),"rot" : 0	},
	2 :  {"obj" : load("res://assets/models/NODE_1.obj"), "rot" : 60	},
	4 :  {"obj" : load("res://assets/models/NODE_1.obj"), "rot" : 120 },
	8 :  {"obj" : load("res://assets/models/NODE_1.obj"), "rot" : 180 },
	16 : {"obj" : load("res://assets/models/NODE_1.obj"), "rot" : 240},
	32 : {"obj" : load("res://assets/models/NODE_1.obj"), "rot" : 300},	
	
	9 : {"obj" : load("res://assets/models/NODE_2_STRAIGHT.obj"), "rot" : 0
	},	
	18 : {"obj" : load("res://assets/models/NODE_2_STRAIGHT.obj"), "rot" : 60},	
	36 : {"obj" : load("res://assets/models/NODE_2_STRAIGHT.obj"), "rot" : 120},	
	
	5 : {"obj" : load("res://assets/models/NODE_2_BEND.obj"), "rot" : 0 },	
	10 : {"obj" : load("res://assets/models/NODE_2_BEND.obj"), "rot" : 60 },	
	20 : {"obj" : load("res://assets/models/NODE_2_BEND.obj"), "rot" : 120 },	
	40 : {"obj" : load("res://assets/models/NODE_2_BEND.obj"), "rot" : 180 },	
	34 : {"obj" : load("res://assets/models/NODE_2_BEND.obj"), "rot" : 240 },	
	
	3 : {"obj" : load("res://assets/models/NODE_2_TIGHT.obj"), "rot" : 0 },	
	6 : {"obj" : load("res://assets/models/NODE_2_TIGHT.obj"), "rot" : 60 },	
	12 : {"obj" : load("res://assets/models/NODE_2_TIGHT.obj"), "rot" : 120 },	
	24 : {"obj" : load("res://assets/models/NODE_2_TIGHT.obj"), "rot" : 180 },
	48 : {"obj" : load("res://assets/models/NODE_2_TIGHT.obj"), "rot" : 240 },
	33: {"obj" : load("res://assets/models/NODE_2_TIGHT.obj"), "rot" : 300 },			
	
	
	
	21: {"obj" : load("res://assets/models/NODE_3_FORK.obj"), "rot" : 0},
	42: {"obj" : load("res://assets/models/NODE_3_FORK.obj"), "rot" : 60},
	
	
	
	45: {"obj" : load("res://assets/models/NODE_4_X.obj"), "rot" : 0},
	37: {"obj" : load("res://assets/models/NODE_4_X.obj"), "rot" : 0},
	
	15: {"obj" : load("res://assets/models/NODE_4_SIDE.obj"),"rot" : 0},




	63: {
		"obj" : load("res://assets/models/NODE_6.obj"),
		"rot" : 0
	},
	
	
}
