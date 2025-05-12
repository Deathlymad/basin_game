extends Label

func _ready():
	ControlState.height_update_signal.connect(update_height_display)

func update_height_display():
	text = str(ControlState.aqueduct_height)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_released("aqueduct_up") and ControlState.aqueduct_height < 9:
			ControlState.aqueduct_height += 1
			ControlState.height_update_signal.emit()
		if event.is_action_released("aqueduct_down") and ControlState.aqueduct_height > 0:
			ControlState.aqueduct_height -= 1
			ControlState.height_update_signal.emit()
