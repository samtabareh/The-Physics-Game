class_name Level extends Node

enum { MISSING_NODE, MISSING_EXPORT }

#region On-Ready(s)
@onready var hud: HUD
@onready var machine: Machine
@onready var win_area: WinArea
@onready var camera: Camera2D

@onready var level_data: LevelData = LevelHandler.current_level

## Used to time the amount of time the player takes for them to finish
@onready var level_timer := Timer.new()
#endregion

## Next level to go to. Automatically set as
## the next level in the category if not set.
## And if that doesn't exist then it's set to the main menu.  
@export var next_scene: PackedScene
## Average time to beat level
@export var avg_time: float

## Path of the next level
var next_level: String
## Machine parts in the level
var level_parts: Array[MachinePart] = []
var time_spent := 0.0
var score := 3.0

func _ready():
	if !next_scene:
		if LevelHandler.next_level(): next_level = LevelHandler.next_level().Path
		else: next_level = "res://Scenes/Main Menu/Main.tscn"
	else: next_level = next_scene.resource_path
	if !avg_time: report_missing(MISSING_EXPORT, "Avg Time")
	
	# Find the machine and hud and set their references
	for node in get_children():
		if node is HUD: hud = node
		elif node is Machine: machine = node
		elif node is WinArea: win_area = node
		elif node is Camera2D: camera = node
		elif node is MachinePart: level_parts.append(node)
	
	level_timer.wait_time = 1
	level_timer.timeout.connect(func (): time_spent += 1)
	add_child(level_timer)
	
	if camera: pass
	else: report_missing(MISSING_NODE, "Camera2D")
	
	if hud:
		hud.next_level = next_level
		# Setting up part info connection
		for part in level_parts:
			part.show_info.connect(hud.show_part_collection)
		
	else: report_missing(MISSING_NODE, "HUD")
	
	if machine:
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
		
		if hud:
			hud.machine_start_button.button_down.connect(machine.start_movement)
			if win_area: machine.movement_end.connect(has_player_won)
	else: report_missing(MISSING_NODE, "Machine")
	
	if win_area: pass
	else: report_missing(MISSING_NODE, "WinArea")

func _process(delta):
	if hud and machine:
		if hud.left_move.is_pressed(): machine.move(-1)
		if hud.right_move.is_pressed(): machine.move(1)

func report_missing(type: int, missing_name: String):
	if type == MISSING_NODE:
		push_error("%s not found in level %s %s" % [missing_name, level_data.Category, level_data.Name])
	if type == MISSING_EXPORT:
		push_error("%s not set in level %s %s" % [missing_name, level_data.Category, level_data.Name])

func has_player_won(has_won: bool = win_area.machine_in_area):
	var extra_time: float = abs(level_timer.time_left-1)
	level_timer.stop()
	
	# The player won
	if has_won:
		# Calculates the score of the player
		var leftover_joules = machine.get_property(machine.JOULES_STORED)
		var leftover_time : float = time_spent + extra_time - avg_time
		
		if leftover_joules <= time_spent / 10: score -= 1
		
		# If the time is higher than the avg, decrease score
		if leftover_time >= 0: score -= 0.25
		# If the time is even higher, decrease the score even more
		if leftover_time >= avg_time/2: score -= 0.75
		
		var mm_coins := 0
		
		if !LevelHandler.is_level_beaten(level_data):
			mm_coins =  round(score * 10)
			MainHandler.give_mm_coins(mm_coins)
		elif LevelHandler.is_better_level_score(level_data, score):
			mm_coins =  round((score - LevelHandler.BeatenLevels[level_data]) * 10)
			MainHandler.give_mm_coins(mm_coins)
		
		# Register beaten level
		LevelHandler.beat_level(level_data, score)
		
		if hud: hud.show_end_level_menu(true, score, mm_coins)
	
	# The player didnt win
	else: if hud: hud.show_end_level_menu(false)
