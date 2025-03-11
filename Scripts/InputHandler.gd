extends BaseHandler

var picked_up_part: MachinePart

func _input(event):
	if Input.is_action_just_released("Click"):
		if picked_up_part: drop_part()
	
	if event is InputEventMouseMotion:
		if picked_up_part: picked_up_part.position = get_global_mouse_position()
	
	# ----Dev----
	if Input.is_action_just_released("dev"):
		MainHandler.is_dev = !MainHandler.is_dev
	if Input.is_action_just_released("dev-rst") && MainHandler.is_dev: SaveHandler.delete_save()

func pick_up_part(part: MachinePart):
	drop_part()
	picked_up_part = part

func drop_part():
	if !picked_up_part: return
	picked_up_part.drop()
	picked_up_part = null
