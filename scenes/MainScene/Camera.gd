extends Node3D



const look_sensitivity = 0.002
var move_speed = 1
var zoom_speed = 3
var zoom_level = 1

var to_camera
var allowRot := false
var allowPan := false

func _ready():	
	$Camera3D.look_at(global_transform.origin, Vector3.UP)	
	

func _unhandled_input(event: InputEvent) -> void:
	
	if Input.is_action_pressed("Right_Click") and event.is_pressed():
		allowRot = true
	if Input.is_action_pressed("Right_Click") and event.is_released():
		allowRot = false
		
	if Input.is_action_pressed("Middle_Click") and event.is_pressed():
		allowPan = true
	if Input.is_action_pressed("Middle_Click") and event.is_released():
		allowPan = false
	
	if event is InputEventMouseMotion and allowRot:
		rotation.y -= event.relative.x * look_sensitivity
		rotation.x -= event.relative.y * look_sensitivity
		rotation.x = clamp(rotation.x, -PI/3, 0)		
	
	if event is InputEventMouseMotion and allowPan:
		var input = Vector3.ZERO
		if Input.is_action_pressed("forward"):
			input.z -= 1
		if Input.is_action_pressed("backward"):
			input.z += 1
		if Input.is_action_pressed("left"):
			input.x -= 1
		if Input.is_action_pressed("right"):
			input.x += 1
			
		input = input.normalized()
		
	
	
	
	

	if Input.is_action_pressed("ZoomOut"):
		
		if zoom_level < 3:
			zoom_level *= 1.05
			$Camera3D.position *= 1.05
	
	if Input.is_action_pressed("ZoomIn"):
		
		if zoom_level > 0.5:
			zoom_level *= 0.95
			$Camera3D.position *= 0.95

	if Input.is_action_just_pressed("SpeedUp"):
		move_speed = 4;
	if Input.is_action_just_released("SpeedUp"):
		move_speed = 1;

func _process(delta):
	
	
	
	
	
	if !allowPan:
		var input = Vector3.ZERO
		if Input.is_action_pressed("forward"):
			input.z -= 1
		if Input.is_action_pressed("backward"):
			input.z += 1
		if Input.is_action_pressed("left"):
			input.x -= 1
		if Input.is_action_pressed("right"):
			input.x += 1
			
		input = input.normalized()
		
		var direction = Basis(Vector3.UP, rotation.y) * input
		position += direction * move_speed * delta 
	
	
		
