extends Main

signal clicked

func _input(event):
	if Input.is_action_just_released("click"): clicked.emit()
	
	if event is InputEventMouseMotion:
		pass
	
	if Input.is_action_just_released("dev"):
		Main.is_dev = !Main.is_dev
		push_warning("is_dev: ", Main.is_dev)
