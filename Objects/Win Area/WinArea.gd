class_name WinArea extends Area2D

signal win_timer_started(timer: Timer)

@export var win_time := 3.0

@onready var win_timer: Timer = $WinTimer

var machine_in_area := false

func _on_body_entered(body):
	if !body is Machine: return
	# print(is_instance_of(body, Machine), body is )
	
	# If its the first time that the machine is entering the area, start the timer
	if win_timer.is_stopped():
		win_timer.start(win_time)
		win_timer_started.emit(win_timer)
	body.end_movement()
	machine_in_area = true

func _on_body_exited(body):
	machine_in_area = false
