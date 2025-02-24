class_name MachinePart extends Node2D

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
	TranslationHandler.updated_lang.connect(update_tooltip)
	update_tooltip(TranslationHandler.locale)

# locale is a param because of the signal its connected to (TH.updated_lang)
## Updates the tooltip of the part to the current locale
func update_tooltip(locale: String):
	var i = 0
	var props := tr(properties.name) + "\n"
	for prop in properties.properties_values:
		if prop != 0:
			var text = "Part_Tooltip_"+MachinePartProperties.get_property_name(i, 0, true)
			props += TranslationHandler.translate_string(text, [prop]) + "\n"
		i += 1
	
	texture.tooltip_text = props

func drop():
	if !picked_up: return
	InputHandler.picked_up_part = null
	if !connector.is_connected_to_connector: position = first_pos

func _on_area_input(viewport, event, shape_idx):
	if Input.is_action_just_pressed("Click"):
		if !picked_up and !InputHandler.picked_up_part:
			InputHandler.pick_up_part(self)
