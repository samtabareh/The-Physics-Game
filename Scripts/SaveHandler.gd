extends BaseHandler

const save_dir = "user://"
const save_name = "save.MachineMaker"
const save_path = save_dir + save_name

func _ready():
	SaveHandler.load_game()

func save_game():
	var save_dict: Dictionary = {
		"Unlocked_Levels": [],
		"Unlocked_Parts": []
	}
	
	for leveldata in LevelHandler.UnlockedLevels:
		save_dict["Unlocked_Levels"].append(leveldata.Path)
	
	for part in MainHandler.unlocked_parts:
		save_dict["Unlocked_Parts"].append(part.name)
	
	var save = FileAccess.open(save_path, FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	
	save.store_var(json_string)
	print_as("Saved game file to: "+OS.get_user_data_dir()+"/"+save_name)

func load_game():
	print_as("Loading save...")
	if not FileAccess.file_exists(save_path):
		print_as("Save file doesnt exist!")
		return
	
	var save = FileAccess.open(save_path, FileAccess.READ)
	while save.get_position() < save.get_length():
		var json_string = save.get_var()
		
		var json = JSON.new()
		
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print_as("[color=red]JSON Parse Error: "+ json.get_error_message()+
			" in "+ json_string+ " at line "+ json.get_error_line()+ "[/color]")
			continue
		
		var data = json.get_data()
		
		for i in data.keys(): 
			# If the string is for Unlocked Levels
			if i == "Unlocked_Levels": for path in data[i]:
				var leveldata: LevelData = LevelHandler.get_level_from_path(path)
				LevelHandler.unlock_level(leveldata)
			
			elif i == "Unlocked_Parts": for key in data[i]:
				var part: MachinePartProperties = MainHandler.get_part_prop_from_name(key)
				MainHandler.unlock_part(part)
	
	print_as("Loaded save successfuly!")

func delete_save():
	DirAccess.remove_absolute(save_path)
	LevelHandler.UnlockedLevels = []
	print_as("Reset save")
