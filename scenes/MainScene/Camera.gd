extends Node3D



const look_sensitivity = 0.002
var move_speed = 1
var zoom_speed = 3
var zoom_level = 1

var to_camera
var allowRot := false
var allowPan := false

var hasInput := false

var input := Vector3.ZERO


func _ready():	
	$Camera3D.look_at(global_transform.origin, Vector3.UP)	
	

func _unhandled_input(event: InputEvent) -> void:
	
	
	
	if event is InputEventMouseMotion and allowRot:
		rotation.y -= event.relative.x * look_sensitivity
		rotation.x -= event.relative.y * look_sensitivity
		rotation.x = clamp(rotation.x, -PI/3, 0)		
	
	if event is InputEventMouseMotion and allowPan:		
		input.z = -event.relative.y
		input.x = -event.relative.x
		
			
		input = input.normalized()
		hasInput = true
		
	
	
	
	

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
	if Input.is_action_pressed("Right_Click"):
		allowRot = true
	if Input.is_action_just_released("Right_Click") :
		allowRot = false
		
	if Input.is_action_pressed("Middle_Click"):
		allowPan = true
		move_speed = 20 * zoom_level;
	if Input.is_action_just_released("Middle_Click"):
		allowPan = false
		move_speed = 1;
	
	if !allowPan:
		if Input.is_action_pressed("forward"):
			input.z -= 1
		if Input.is_action_pressed("backward"):
			input.z += 1
		if Input.is_action_pressed("left"):
			input.x -= 1
		if Input.is_action_pressed("right"):
			input.x += 1
		
		input = input.normalized()		
		hasInput = true
	
	if hasInput:
		var direction = Basis(Vector3.UP, rotation.y) * input	
		position += direction * move_speed * delta 
		input = Vector3.ZERO
