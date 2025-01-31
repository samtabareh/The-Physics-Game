extends BaseHandler

signal mouse_pressed
signal mouse_released

var picked_up_part : MachinePart

func _input(event):
	if Input.is_action_just_pressed("Click"):
		mouse_pressed.emit()
	if Input.is_action_just_released("Click"):
		mouse_released.emit()
		if picked_up_part: drop_part()
	
	if event is InputEventMouseMotion:
		if picked_up_part: picked_up_part.position = get_global_mouse_position()
	
	# ----Dev----
	if Input.is_action_just_released("dev"):
		Main.is_dev = !Main.is_dev
		push_warning('"is_dev": ', Main.is_dev)
	if Input.is_action_just_pressed("dev-lvl"): LevelHandler.change_level("res://Scenes/Main Menu/Levels.tscn")
	if Input.is_action_just_released("dev-rst") && Main.is_dev: SaveHandler.delete_save()

func pick_up_part(part: MachinePart):
	drop_part()
	picked_up_part = part

func drop_part():
	if !picked_up_part: return
	picked_up_part.drop()
	picked_up_part = null
