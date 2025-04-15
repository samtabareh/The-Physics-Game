extends Node2D

@onready var display_text: DisplayText = $"../DisplayText"
@onready var win_area: WinArea = $"../WinArea"
@onready var machine: Machine = $"../Machine"
@onready var part_f1: MachinePart = $"../Part"
@onready var part_b1: MachinePart = $"../Part2"

func _ready():
	display_text.text(["Tutorial_1-1", "Tutorial_1-2", "Tutorial_1-3"])
	await display_text.writing_finished
	machine.show()
	display_text.is_up = true
	display_text.text(["Tutorial_1-4"])
	await display_text.writing_finished
	part_f1.show()
	part_b1.show()
	display_text.is_up = false
	display_text.text(["Tutorial_1-5", "Tutorial_1-6", "Tutorial_1-7",
	"Tutorial_1-8", "Tutorial_1-9", "Tutorial_1-10", "Tutorial_1-11"])
	await display_text.writing_finished
	await machine.connectors[0].connection_changed
	win_area.show()
	display_text.is_up = true
	display_text.text(["Tutorial_1-12", "Tutorial_1-13", "Tutorial_1-14"])
	await display_text.writing_finished
