extends Node2D

@onready var levels = $CanvasLayer/Levels

func _ready():
	if LevelHandler.UnlockedLevels.is_empty(): return
	
	for leveldata in LevelHandler.UnlockedLevels:
		var sort = get_node_or_null("CanvasLayer/Levels/"+leveldata.Category)
		if sort == null:
			sort = VBoxContainer.new()
			sort.name = leveldata.Category
			levels.add_child(sort)
		
		# Make the levels button
		var button : Button = $CanvasLayer/Game/Exit.duplicate()
		# set its name
		button.name = leveldata.Category+" "+leveldata.Name.get_slice(".tscn", 0)
		# set its text in case its not being translated
		button.text = button.name
		# because its a dupe of exit its connected to the exit method and will exit when pressed...
		# so we disconnect it from that method.
		button.pressed.disconnect(_on_exit_pressed)
		# and connect it to the method we want.
		button.pressed.connect(level_pressed.bind(leveldata))
		# add the button as the child of its category sort.
		sort.add_child(button)

func level_pressed(leveldata: LevelData):
	LevelHandler.change_level(leveldata)

func _on_exit_pressed():
	Main.exit()

func _on_main_menu_pressed():
	LevelHandler.change_level("res://Scenes/Main Menu/Main.tscn")
