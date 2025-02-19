extends BaseHandler

## { "Category": { 1: LevelData, 2: LevelData2 }, "Category2": { 1: LevelData } }
var Levels := {}
## Contains the path for levels not the levels
var UnlockedLevels : Array[LevelData] = []

const path = "res://Scenes/Levels/"

@onready var current_level : LevelData :
	get:
		var temp = get_tree().current_scene.scene_file_path
		for category in Levels.values(): for leveldata : LevelData in category.values():
				if leveldata.Path == temp:
					current_level = leveldata
					return current_level
		return

func _ready():
	LevelHandler.init_levels()

func init_levels():
	Levels = {}
	var dir = DirAccess.open(path)
	load_levels(dir)
	unlock_level(Levels["Tutorial"][1])

func load_levels(dir: DirAccess):
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Example: ["Scenes", "Levels", "Tutorial"]
			var folder_name = dir.get_current_dir().split("/")
			folder_name = folder_name[-1]
			
			if file_name.get_extension() == "remap":
				file_name = file_name.trim_suffix(".remap")
			
			if not dir.current_is_dir():
				print_as("Found [color=cyan]file[/color]: "+file_name)
				
				var num = file_name.get_slice("_",1)
				num = num.get_slice(".",0)
				
				var file_path = path+folder_name+'/'+file_name
				
				if file_name.split(".", 1)[1] == "tscn":
					print_as("Adding [color=cyan]file[/color]: "+ file_path+ " to "+ folder_name)
					
					if Levels.get(folder_name) == null:
						Levels[folder_name] = {}
					var leveldata = LevelData.LevelData(int(num),file_name,folder_name,file_path)
					Levels[folder_name][leveldata.Id] = leveldata
			else:
				print_as("Found [color=magenta]directory[/color]: "+ file_name)
				Levels[folder_name] = {}
				
				var new_dir = DirAccess.open(dir.get_current_dir()+"/"+file_name)
				load_levels(new_dir)
			
			file_name = dir.get_next()
	else:
		print_as("[color=red]An error occurred when trying to access the path. Error: "+
		str(DirAccess.get_open_error())+ "[/color]")
	Levels.erase("Levels")

func next_level() -> LevelData:
	var next = Levels[current_level.Category].get(current_level.Id+1)
	if next == null: push_error("No other level exists")
	return next

func get_level_from_path(path : String):
	if Levels.is_empty(): return
	for category in Levels.values():
		for level : LevelData in category.values():
			if path == level.Path: return level

func change_level(level):
	if level is String:
		get_tree().change_scene_to_file(level)
	elif level is LevelData:
		unlock_level(level)
		get_tree().change_scene_to_file(level.Path)
	else: push_error("Invalid level given, expected a LevelData res or path String.")

func is_level_unlocked(level: LevelData) -> bool:
	return UnlockedLevels.has(level)

func unlock_level(level: LevelData):
	if !is_level_unlocked(level): UnlockedLevels.append(level)
