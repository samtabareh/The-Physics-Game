extends Node2D

@onready var display_text: DisplayText = $"../DisplayText"

func _ready():
	display_text.text(["HELLO"])
