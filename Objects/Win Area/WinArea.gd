class_name WinArea extends Area2D

signal machine_entered(machine: Machine)

var machine_in_area := false

func _on_body_entered(body):
	if !body is Machine: return
	machine_in_area = true
	machine_entered.emit(body)
	body.end_movement()

func _on_body_exited(body):
	machine_in_area = false
