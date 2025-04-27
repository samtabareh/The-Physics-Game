class_name WinArea extends Area2D

signal machine_entered(machine: Machine)

## Only flips in-game, not in the editor
@export var flip_horizontal := false :
	set(v):
		$Sprite2D.flip_h = v
		var temp = 30 - $CollisionShape2D.shape.size.x
		$Sprite2D.position.x = abs(temp) if v else temp
		

var machine_in_area := false

func _on_body_entered(body):
	if !body is Machine: return
	machine_in_area = true
	machine_entered.emit(body)
	body.end_movement()

func _on_body_exited(body):
	machine_in_area = false
