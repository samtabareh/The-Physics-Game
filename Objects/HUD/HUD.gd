class_name HUD extends Node2D


#region Menu
@onready var options_layer: CanvasLayer = $Menu
#endregion

#region Main
@onready var hud_layer: CanvasLayer = $Main

@onready var machine_start_button: Button = $Main/Start
@onready var left_move: TouchScreenButton = $Main/Left
@onready var right_move: TouchScreenButton = $Main/Right
#endregion

#region Level End
@onready var level_end_layer: CanvasLayer = $"Level End"

@onready var end_background: ColorRect = %Background
@onready var end_display: PanelContainer = %EndDisplay
@onready var mm_coin: HBoxContainer = %MMCoin
@onready var mm_coin_text: Label = %MMCoinText
@onready var score_display: TextureProgressBar = %ScoreDisplay
@onready var score_text: Label = %ScoreText
@onready var next_level_button: Button = %"Next Level"
#endregion

var next_level: String

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

func show_end_level_menu(won: bool, score: float = 0, mm_coins: int = 0):
	if won:
		score_display.value = score
		score_text.text = "%s  /  3" % score
		
		mm_coin.show()
		mm_coin_text.text = str(mm_coins)
		
		next_level_button.show()
	
	level_end_layer.show()
	
	var t = create_tween().set_parallel()
	t.tween_property(end_background, "modulate", Color(1, 1, 1 ,1), 0.5)
	t.tween_property(end_display, "modulate", Color(1, 1, 1 ,1), 0.5)

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

func _on_next_level_pressed():
	LevelHandler.change_level(next_level)
