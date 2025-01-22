extends Main

var path = "res://Resources/"

func _ready():
	TypesLoader.init_dicts()

func init_dicts():
	var dir = DirAccess.open(path)
	load_dir(dir)

func load_dir(dir : DirAccess):
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			var folder_name = dir.get_current_dir().split("/")
			folder_name = folder_name[folder_name.size()-1]
			
			# Prevents a bug where when the game is exported from godot all resources
			# have a .remap added at the end of the file name, so we will remove it from our
			# string to prevent issues.
			if file_name.ends_with(".remap"):
				file_name = file_name.trim_suffix(".remap")
			
			if not dir.current_is_dir():
				Main.print_as("Found [color=cyan]file[/color]: "+ file_name)
			
				if file_name.ends_with(".tres"):
					var file_path = path+folder_name+"/"+file_name
					var res = load(file_path)
					
					# Add res file to resources registry
			else:
				print_as("Found [color=magenta]directory[/color]: " + file_name)
				var new_dir = DirAccess.open(dir.get_current_dir()+"/"+file_name)
				load_dir(new_dir)
			
			file_name = dir.get_next()

var Atoms : Dictionary = {}
var Molecules : Dictionary = {}
