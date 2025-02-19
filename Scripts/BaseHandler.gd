class_name BaseHandler extends Node2D

func print_as(Message):
	# stack structure -> [{"function":"foo", "line":1, "source":"res://temp/self.gd"}]
	var id: String = get_stack()[1]["source"]
	id = id.get_file().get_slice(".", 0)
	
	var color = (
	"green" if id == "SaveHandler" else 
	"orange" if id == "TranslationSwitcher" else
	"purple" if id == "LevelHandler" else
	"yellow")
	
	print_rich("[color=%s][%s][/color] %s" % [color, id, Message])
