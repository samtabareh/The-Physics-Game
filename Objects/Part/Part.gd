## Abstract class that the parts will inherit
class_name MachinePart extends Node2D

@export var properties := MachinePartProperties.new()
## The position it would reset to when its dragged and not connected
@onready var first_pos := position

@onready var connector: Connector = %"Connector"
@onready var texture: TextureRect = %"Texture"

var mouse_contact := false
var picked_up := false :
	get:
		return self == InputHandler.picked_up_part

func _ready():
	InputHandler.mouse_pressed.connect(_on_mouse_pressed)
	
	#texture.texture = properties.texture
	texture.set_anchors_preset(Control.PRESET_CENTER)

func _on_mouse_pressed():
	if !mouse_contact: return
	
	if !picked_up and !InputHandler.picked_up_part:
		InputHandler.pick_up_part(self)

func drop():
	if !picked_up: return
	InputHandler.picked_up_part = null
	if !connector.is_connected_to_connector: position = first_pos

func _on_area_mouse_entered():
	mouse_contact = true

func _on_area_mouse_exited():
	mouse_contact = false
