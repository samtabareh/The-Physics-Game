class_name Collection extends CanvasLayer

@onready var current_page: RichTextLabel
@onready var selectors = $TabContainer/Parts/Selectors
@onready var descriptions = $TabContainer/Parts/Descriptions
@onready var tab_container = $TabContainer

func _ready():
	TranslationHandler.updated_lang.connect(update_translation)
	
	tab_container.set_tab_title(0, tr("Parts"))
	tab_container.set_tab_title(1, tr("Skins"))
	
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

func _exit_tree():
	MainHandler.open_collection = null

## Shows a specific screen from 
func open_part(part):
	var key
	
	# Getting the file name of the part
	if part is String:
		if part.begins_with("MP"): key = MainHandler.get_part_file_name_from_part(part)
		else: key = part
	else: key = MainHandler.get_part_file_name_from_part(part)
	 
	# To prevent two desc(s) being shown at once
	if current_page: go_back()
	
	selectors.hide()
	var desc: RichTextLabel = get_node("TabContainer/Parts/Descriptions/"+key)
	desc.show()
	current_page = desc

## When a selector is clicked, show its desc
func _on_part_meta_clicked(part):
	open_part(part)

func _on_back_pressed():
	go_back()

func go_back():
	if current_page:
		current_page.hide()
		current_page = null
		selectors.show()
	else:
		MainHandler.open_collection = null
		queue_free()

func update_translation(_locale):
	tab_container.set_tab_title(0, tr("Parts"))
	tab_container.set_tab_title(1, tr("Skins"))
	
	for selector in selectors.get_children():
		if selector.name == "Base": continue
		
		selector.text = '[url="%s"]- %s[/url]' % [selector.name, tr(TypesLoader.part_properties.get(selector.name).name)]
	for description in descriptions.get_children():
		if description.name == "Base": continue
		
		var part_prop = TypesLoader.part_properties.get(description.name)
		
		var i = 0
		var desc_text := tr(part_prop.name) + "\n"
		for prop in part_prop.properties_values:
			if prop != 0:
				var text = "Part_Tooltip_"+MachinePartProperties.get_property_name(i, 0, true)
				desc_text += TranslationHandler.translate_string(text, [prop]) + "\n"
			i += 1
		description.text = desc_text

static func create_new(node: Node) -> Collection:
	if MainHandler.open_collection: return
	var c = load("res://Objects/Collection/Collection.tscn").instantiate()
	node.add_child(c)
	MainHandler.open_collection = c
	return c
