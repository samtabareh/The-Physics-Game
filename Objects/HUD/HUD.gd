class_name HUD extends Node2D

#region OnReady(s)
@onready var options_layer = $Menu
@onready var hud_layer = $Main

@onready var machine_start_button: Button = $Main/Start
@onready var left_move: TouchScreenButton = $Main/Left
@onready var right_move: TouchScreenButton = $Main/Right
@onready var restart_button: Button = $Main/Restart
#endregion

func _ready():
	machine_start_button.set_anchors_and_offsets_preset(
		Control.PRESET_CENTER_BOTTOM,
		Control.PRESET_MODE_KEEP_SIZE,
		10)

func _input(event):
	if Input.is_action_just_released("Exit"): set_options_layer_visible()

# To turn off/on menu ui
# If no value, then toggle between layers
func set_options_layer_visible(value = null):
	options_layer.visible = value if value else !options_layer.visible
	hud_layer.visible = !value if value else !hud_layer.visible

func _on_continue_pressed():
	set_options_layer_visible(false)
	get_tree().paused = false

func _on_menu_pressed():
	set_options_layer_visible(true)
	get_tree().paused = true

func _on_restart_pressed():
	LevelHandler.change_level(LevelHandler.current_level)

func show_end_level_menu(won: bool, score: float = 0):
	pass

func _on_save_pressed():
	SaveHandler.save_game()

func _on_main_menu_pressed():
	get_tree().paused = false
	LevelHandler.change_level("res://Scenes/Main Menu/Main.tscn")

func _on_english_pressed():
	TranslationHandler.update_ui("en")

func _on_farsi_pressed():
	TranslationHandler.update_ui("fa")

func _on_exit_pressed():
	MainHandler.exit()

func _on_collection_pressed():
	Collection.create_new(self)

func show_part_collection(part: MachinePartProperties):
	var c := Collection.create_new(self)
	c.open_part(part)
