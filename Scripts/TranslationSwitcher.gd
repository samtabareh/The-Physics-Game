extends BaseHandler

#func _process(delta):
	#update_ui(TranslationServer.get_locale())

func update_ui(lang: String):
	TranslationServer.set_locale(lang)
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
		[TranslationServer.get_locale_name(TranslationServer.get_locale()),lang])
