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
	if MainHandler.is_dev:
		if Input.is_action_just_released("dev-rst"): SaveHandler.delete_save()
		if Input.is_action_just_pressed("dev-ual"):
			for category in LevelHandler.Levels.keys():
				for level_data in LevelHandler.Levels.get(category).values():
					LevelHandler.unlock_level(level_data)
		

func pick_up_part(part: MachinePart):
	drop_part()
	picked_up_part = part

func drop_part():
	if !picked_up_part: return
	picked_up_part.drop()
	picked_up_part = null
