class_name Level extends Node

@export var leveldata: LevelData

@export var hud: HUD
@export var machine: Machine


func _ready():
	for node in get_children():
		if node is Machine: machine = node
		elif node is HUD: hud = node
	
	if machine and hud.machine_start_button: hud.machine_start_button.button_down.connect(machine.begin_movement)
	else: push_error("Machine or Start button not set in level "+ LevelHandler.current_level.Name)
