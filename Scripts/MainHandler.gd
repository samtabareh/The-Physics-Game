extends BaseHandler

var is_dev := false

@onready var is_dev_label := Label.new()

func _ready():
	is_dev_label.visible = false
	add_child(is_dev_label)

func set_dev_mode(value: bool):
	is_dev = value
	is_dev_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	is_dev_label.text = "is_dev: %s" % is_dev
	is_dev_label.visible = is_dev
	
	print_as("is_dev: %s" % is_dev)

func exit():
	await SaveHandler.save_game()
	get_tree().quit()
