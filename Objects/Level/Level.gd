class_name Level extends Node

@onready var hud: HUD
@onready var machine: Machine
@onready var win_area: WinArea
@onready var camera: Camera2D

@onready var level_timer := Timer.new()

@export var avg_time: float

var time_spent := 0
var score := 3.0

func _ready():
	if !avg_time: push_error("No avg_time set for level %s %s" % [LevelHandler.current_level.Category, LevelHandler.current_level.Name])
	
	# Find the machine and hud and set their references
	for node in get_children():
		if node is HUD: hud = node
		elif node is Machine: machine = node
		elif node is WinArea: win_area = node
		elif node is Camera2D: camera = node
	
	level_timer.wait_time = 1
	level_timer.timeout.connect(func (): time_spent += 1)
	add_child(level_timer)
	
	if camera: pass
	else: report_missing_node("Camera2D")
	
	# Connect the start button to the movement function
	if machine:
		machine.movement_start.connect(func ():
			level_timer.start()
			
			# Smoothly zooms and moves the camera to the machine, then switches cameras
			var tween = create_tween()
			tween.tween_property(camera, "global_position", machine.position, 1)
			tween.parallel().tween_property(camera, "zoom", Vector2(1.5, 1.5), 1)
			await tween.finished
			machine.camera.enabled = true
			camera.enabled = false
			)
		
		if hud: hud.machine_start_button.button_down.connect(machine.start_movement)
		else: report_missing_node("HUD")
	else: report_missing_node("Machine")
	
	if win_area:
		win_area.win_timer.timeout.connect(has_player_won.bind(win_area.machine_in_area))
		if hud: win_area.win_timer_started.connect(hud._on_win_timer_started)
		else: report_missing_node("HUD")
	else: report_missing_node("WinArea")

func report_missing_node(node_name: String):
	push_error("%s not found in level %s %s" % [node_name, LevelHandler.current_level.Category, LevelHandler.current_level.Name])
	
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
	# The player didnt win
	else: pass
