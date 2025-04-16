extends BaseHandler

const save_dir = "user://"
const save_name = "save.MachineMaker"
const save_path = save_dir + save_name

func _ready():
	SaveHandler.load_game()

func save_game():
	var save_dict: Dictionary = {
		"Unlocked_Levels": [],
		"Beaten_Levels": {},
		"Unlocked_Parts": [],
		"Unlocked_Skins": [],
		"MM_Coins": 0,
		"Machine_Scraps": 0
	}
	
	save_dict["MM_Coins"] = MainHandler.mm_coins
	save_dict["Machine_Scraps"] = MainHandler.machine_scraps
	
	for levelData in LevelHandler.UnlockedLevels:
		if !levelData is LevelData:
			push_error("Non-LevelData in unlocked levels list found.")
			LevelHandler.UnlockedLevels.erase(levelData)
			continue
		
		save_dict["Unlocked_Levels"].append(levelData.Path)
	
	for levelData in LevelHandler.BeatenLevels.keys():
		if !levelData is LevelData:
			push_error("Non-LevelData in beaten levels list found.")
			LevelHandler.BeatenLevels.erase(levelData)
			continue
		
		var score: float = LevelHandler.BeatenLevels[levelData]
		save_dict["Beaten_Levels"][levelData.Path] = score
	
	for part in MainHandler.unlocked_parts:
		save_dict["Unlocked_Parts"].append(part.name)
	
	#for skin in MainHandler.unlocked_skins:
		#save_dict["Unlocked_Skins"].append(skin.id)
	
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
			if i == "MM_Coins": MainHandler.mm_coins = data[i]
			elif i == "Machine_Scraps": MainHandler.machine_scraps = data[i]
			
			elif i == "Unlocked_Levels": for path in data[i]:
				if LevelHandler.get_level_from_path(path) != null:
					var leveldata: LevelData = LevelHandler.get_level_from_path(path)
					LevelHandler.unlock_level(leveldata)
				else:
					print_as("Missing level found in save file.")
					push_error("Missing level found in save file.")
					print_as(i+": "+data[i])
			elif i == "Beaten_Levels": for path in data[i].keys():
				if LevelHandler.get_level_from_path(path) != null:
					var leveldata: LevelData = LevelHandler.get_level_from_path(path)
					LevelHandler.beat_level(leveldata, data[i][path])
				else:
					print_as("Missing level found in save file.")
					push_error("Missing level found in save file.")
					print_as(i+": "+str(data[i]))
			
			elif i == "Unlocked_Parts": for key in data[i]:
				var part: MachinePartProperties = MainHandler.get_part_prop_from_name(key)
				MainHandler.unlock_part(part)
	
	print_as("Loaded save successfuly!")

func delete_save():
	DirAccess.remove_absolute(save_path)
	LevelHandler.UnlockedLevels = []
	LevelHandler.BeatenLevels = {}
	MainHandler.unlocked_parts = []
	MainHandler.unlocked_skins = []
	MainHandler.mm_coins = 0
	print_as("Reset save")
