extends Node2D

func _on_exit_pressed():
	MainHandler.exit()

func _on_levels_pressed():
	LevelHandler.change_level("res://Scenes/Main Menu/Levels.tscn")

func _on_collection_pressed():
	Collection.create_new(self)

func _on_settings_pressed():
	LevelHandler.change_level("res://Scenes/Main Menu/Settings.tscn")

func _on_save_pressed():
	SaveHandler.save_game()

func _on_load_pressed():
	SaveHandler.load_game()

func _on_en_pressed():
	TranslationHandler.update_ui("en")

func _on_fa_pressed():
	TranslationHandler.update_ui("fa")
