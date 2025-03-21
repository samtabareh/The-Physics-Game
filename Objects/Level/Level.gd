class_name Level extends Node

enum { MISSING_NODE, MISSING_EXPORT }

#region On-Readies
@onready var hud: HUD
@onready var machine: Machine
@onready var win_area: WinArea
@onready var camera: Camera2D

@onready var level_timer := Timer.new()
#endregion

## Average time to beat level
@export var avg_time: float

## Parts of the level (mainly used for referencing)
var level_parts: Array[MachinePart] = []
var time_spent := 0
var score := 3.0

func _ready():
	if !avg_time: report_missing(MISSING_EXPORT, "Avg Time")
	
	# Find the machine and hud and set their references
	for node in get_children():
		if node is HUD: hud = node
		elif node is Machine: machine = node
		elif node is MachinePart: level_parts.append(node)
		elif node is WinArea: win_area = node
		elif node is Camera2D: camera = node
	
	level_timer.wait_time = 1
	level_timer.timeout.connect(func (): time_spent += 1)
	add_child(level_timer)
	
	if camera: pass
	else: report_missing(MISSING_NODE, "Camera2D")
	
	if hud:
		# Setting up part info connection
		for part in level_parts:
			part.show_info.connect(hud.show_part_collection)
		
	else: report_missing(MISSING_NODE, "HUD")
	
	if machine:
		machine.out_of_joules.connect(out_of_joules)
		
		machine.movement_start.connect(func ():
			level_timer.start()
			hud.machine_start_button.visible = false
			if hud:
				hud.left_move.show()
				hud.right_move.show()
			
			# Smoothly zooms and moves the camera to the machine, then switches cameras
			var tween = create_tween()
			tween.tween_property(camera, "global_position", machine.position, 1)
			tween.parallel().tween_property(camera, "zoom", Vector2(1.5, 1.5), 1)
			await tween.finished
			machine.camera.enabled = true
			camera.enabled = false
		)
		
		machine.movement_end.connect(func ():
			if hud:
				hud.left_move.hide()
				hud.right_move.hide()
		)
		
		# Connect the start button to the movement function
		if hud:
			hud.machine_start_button.button_down.connect(machine.start_movement)
			machine.out_of_joules.connect(func ():
				hud.restart_button.show()
				)
	else: report_missing(MISSING_NODE, "Machine")
	
	if win_area:
		win_area.win_timer.timeout.connect(has_player_won.bind(win_area.machine_in_area))
		if hud: win_area.win_timer_started.connect(hud._on_win_timer_started)
	else: report_missing(MISSING_NODE, "WinArea")

func _process(delta):
	if hud and machine:
		if hud.left_move.is_pressed(): machine.move(-1)
		if hud.right_move.is_pressed(): machine.move(1)

func report_missing(type: int, missing_name: String):
	if type == MISSING_NODE:
		push_error("%s not found in level %s %s" % [missing_name, LevelHandler.current_level.Category, LevelHandler.current_level.Name])
	if type == MISSING_EXPORT:
		push_error("%s not set in level %s %s" % [missing_name, LevelHandler.current_level.Category, LevelHandler.current_level.Name])

func out_of_joules():
	pass

func has_player_won(value: bool):
	var extra_time := level_timer.time_left
	level_timer.stop()
	
	# The player won
	if value:
		# Calculates the score of the player
		var leftover_joules = machine.get_property(machine.JOULES_STORED)
		var leftover_time : float = time_spent + extra_time - avg_time
		
		if leftover_joules <= time_spent / 10: score -= 1
		
		# If the time is higher than the avg, decrease score
		if leftover_time >= 0: score -= 0.25
		# If the time is even higher, decrease the score even more
		if leftover_time >= avg_time/2: score -= 0.75
		
		hud.show_end_level_menu(true, score)
	# The player didnt win
	else: hud.show_end_level_menu(false)
