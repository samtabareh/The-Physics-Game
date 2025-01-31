class_name HUD extends Control

@onready var options_layer = $Layer
@onready var hud_layer = $Layer2
@onready var machine_start_button : Button = $Layer2/Start

func _ready():
	machine_start_button.set_anchors_and_offsets_preset(
		Control.PRESET_CENTER_BOTTOM,
		Control.PRESET_MODE_KEEP_SIZE,
		10)

func _input(event):
	if Input.is_action_just_released("Exit"): set_options_layer_visible(false)

func set_options_layer_visible(value: bool):
	options_layer.visible = value
	hud_layer.visible = !value

func _on_continue_pressed():
	set_options_layer_visible(false)
	get_tree().paused = false

func _on_menu_pressed():
	set_options_layer_visible(true)
	get_tree().paused = true

func _on_save_pressed():
	SaveHandler.save_game()

func _on_main_menu_pressed():
	get_tree().paused = false
	LevelHandler.change_level("res://Scenes/Main Menu/Main.tscn")

func _on_english_pressed():
	TranslationSwitcher.UpdateUI("en")

func _on_farsi_pressed():
	TranslationSwitcher.UpdateUI("fa")

func _on_exit_pressed():
	Main.exit()
