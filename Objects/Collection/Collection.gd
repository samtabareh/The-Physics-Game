class_name Collection extends CanvasLayer

@onready var current_page: RichTextLabel
@onready var selectors = $TabContainer/Parts/Selectors
@onready var descriptions = $TabContainer/Parts/Descriptions

func _ready():
	if TypesLoader.part_properties.is_empty(): push_error("No Part Properties loaded for Collection!")
	
	for key in TypesLoader.part_properties.keys():
		var part_prop: MachinePartProperties = TypesLoader.part_properties[key]
		
		var selector: RichTextLabel = $TabContainer/Parts/Selectors/Base.duplicate()
		selector.visible = true
		selector.name = key
		selector.text = '[url="%s"]- %s[/url]' % [key, tr(part_prop.name)]
		
		selectors.add_child(selector)
		
		var description: RichTextLabel = $TabContainer/Parts/Descriptions/Base.duplicate()
		description.visible = false
		description.name = key
		
		# Setting up desc
		var i = 0
		var desc_text := tr(part_prop.name) + "\n"
		for prop in part_prop.properties_values:
			if prop != 0:
				var text = "Part_Tooltip_"+MachinePartProperties.get_property_name(i, 0, true)
				desc_text += TranslationHandler.translate_string(text, [prop]) + "\n"
			i += 1
		description.text = desc_text
		
		descriptions.add_child(description)

func _input(event):
	if Input.is_action_just_pressed("Exit"): _on_back_pressed()

## Shows a specific screen from 
func jump_to_part(part):
	selectors.hide()
	var desc: RichTextLabel = get_node("TabContainer/Parts/Descriptions/"+part)
	desc.show()
	current_page = desc

## When a selector is clicked, show its desc
func _on_part_meta_clicked(part):
	selectors.hide()
	var desc: RichTextLabel = get_node("TabContainer/Parts/Descriptions/"+part)
	desc.show()
	current_page = desc

func _on_back_pressed():
	if current_page:
		current_page.hide()
		selectors.show()
	else: queue_free()

static func create() -> Collection:
	return Collection.new()
