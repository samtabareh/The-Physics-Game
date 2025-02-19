extends Node2D

@onready var levels = $CanvasLayer/Levels

func _ready():
	if LevelHandler.UnlockedLevels.is_empty(): return
	
	var sort = null
	for category in LevelHandler.Levels.keys():
		# If sort doesnt exist or its not this categories sort, then make one + its label
		if !sort or sort.name != category:
			sort = VBoxContainer.new()
			sort.name = category
			levels.add_child(sort)
			
			var label: Label = $CanvasLayer/Label.duplicate()
			label.visible = true
			label.name = category
			label.text = category
			sort.add_child(label)
		
		for leveldata in LevelHandler.Levels.get(category).values():
			# Make the levels button
			var button: Button = $"CanvasLayer/Game/Main Menu".duplicate()
			button.name = category+" "+leveldata.Name.get_slice(".tscn", 0)
			
			# If the level isnt unlocked, then disable the button
			button.disabled = !LevelHandler.is_level_unlocked(leveldata)
			
			# Set its text in case its not being translated
			button.text = button.name
			
			# Because its a dupe of exit, its connected to the exit method
			# so we disconnect it and connect it to the right one
			button.pressed.disconnect(_on_main_menu_pressed)
			button.pressed.connect(level_pressed.bind(leveldata))
			
			# And adding a dev func to the button to unlock it easily
			button.gui_input.connect(button_input.bind(leveldata))
			
			sort.add_child(button)

func button_input(event, leveldata: LevelData):
	if Input.is_action_just_pressed("dev-unl") and MainHandler.is_dev:
		LevelHandler.unlock_level(leveldata)

func level_pressed(leveldata: LevelData):
	LevelHandler.change_level(leveldata)

func _on_main_menu_pressed():
	LevelHandler.change_level("res://Scenes/Main Menu/Main.tscn")
