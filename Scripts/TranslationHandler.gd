extends BaseHandler

signal updated_lang(locale: String)

const default_locale = "fa"

var locale : String :
	get:
		return TranslationServer.get_locale()

func _ready():
	update_ui(default_locale)

func _process(delta):
	update_ui(locale)

func update_ui(locale: String):
	TranslationServer.set_locale(locale)
	var nodes = get_tree().get_nodes_in_group("UI")
	for node in nodes:
		if node.get_child_count() > 0:
			nodes.append_array(node.get_children())
		if node is BaseButton || node is Label:
			node.text = tr(node.name)
	
	# Output to log
	if get_stack().size() > 1:
		var Id : String = get_stack()[1]["source"]
		Id = Id.get_file().get_slice(".", 0)
		if Id != name: print_as("Changed language to: %s | %s" %
		[TranslationServer.get_locale_name(locale), locale])
	updated_lang.emit(locale)

## Used to translate a single string
## With an optional parameter for variables that could be in the string
func translate_string(msg: String, values := []) -> String:
	var trans_msg: String = tr(msg)
	if values: trans_msg = trans_msg.format(values)
	return trans_msg

## Used to translate multiple strings
## With an optional parameter for variables that could be in each string
## msgs example: [ Mass: {0}", "Where did the {0} fox go? to the {1}" ]
## values example: [ [10], ["brown", "forest"] ]
## outputs example: [ "Mass: 10", "Where did the brown fox go? to the forest" ]
func translate_strings(msgs: Array[String], values:= []) -> Array[String]:
	var trans_msgs := []
	var i = 0
	for msg in msgs:
		var trans_msg = TranslationServer.translate(msg)
		if values: trans_msg = trans_msg.format(values[i])
		trans_msgs.append(trans_msg)
	return trans_msgs
