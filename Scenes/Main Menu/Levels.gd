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
		
		# Make the Label for the 
		var label: Label = $CanvasLayer/Label.duplicate()
		label.visible = true
		label.name = leveldata.Category
		sort.add_child(label)
		
		# Make the levels button
		var button: Button = $"CanvasLayer/Game/Main Menu".duplicate()
		button.name = leveldata.Category+" "+leveldata.Name.get_slice(".tscn", 0)
		# Set its text in case its not being translated
		button.text = button.name
		# Because its a dupe of exit, its connected to the exit method so we disconnect it
		button.pressed.disconnect(_on_main_menu_pressed)
		button.pressed.connect(level_pressed.bind(leveldata))
		sort.add_child(button)

func level_pressed(leveldata: LevelData):
	LevelHandler.change_level(leveldata)

func _on_main_menu_pressed():
	LevelHandler.change_level("res://Scenes/Main Menu/Main.tscn")
