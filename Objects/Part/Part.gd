class_name MachinePart extends Node2D

signal show_info(part: MachinePartProperties)

@export var properties := MachinePartProperties.new()
## The position it would reset to when its let go of and its not connected to anything
@onready var first_pos := position

@onready var connector: Connector = %"Connector"
@onready var texture: TextureRect = %"Texture"

var picked_up := false :
	get:
		return self == InputHandler.picked_up_part

func _ready():
	#texture.texture = properties.texture
	texture.set_anchors_preset(Control.PRESET_CENTER)

func drop():
	if !picked_up: return
	InputHandler.picked_up_part = null
	if !connector.is_connected_to_connector: position = first_pos

func _on_area_input(viewport, event, shape_idx):
	# Info of part
	if event is InputEventScreenTouch and event.double_tap:
		show_info.emit(properties)
	
	# Grab part
	elif Input.is_action_just_pressed("Click"):
		if !picked_up and !InputHandler.picked_up_part:
			InputHandler.pick_up_part(self)
