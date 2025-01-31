extends BaseHandler

var is_dev := false

func set_dev_mode(value: bool):
	is_dev = value
	print_as(['"is_dev": ', value])

func exit():
	await SaveHandler.save_game()
	get_tree().quit()
