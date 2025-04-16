extends BaseHandler

## { "Category": { 1: LevelData, 2: LevelData2 }, "Category2": { 1: LevelData } }
var Levels := {}
## Contains the levelData for levels that have been reached
var UnlockedLevels: Array[LevelData] = []
## Contains the levelData for levels that have been beaten, along with the score
var BeatenLevels: Dictionary[LevelData, float] = {}

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
	#if next == null: push_error("No other level exists")
	return next

func get_level_from_path(path : String) -> LevelData:
	if !Levels.is_empty(): for category in Levels.values(): for level: LevelData in category.values():
		if path == level.Path: return level
	return

func change_level(level):
	if level is String:
		var temp = get_level_from_path(level)
		if temp != null: unlock_level(temp)
		get_tree().change_scene_to_file(level)
	elif level is LevelData:
		unlock_level(level)
		get_tree().change_scene_to_file(level.Path)
	else: push_error("Invalid level given, expected a LevelData res or path String.")

func is_level_unlocked(levelData: LevelData) -> bool:
	return UnlockedLevels.has(levelData)

func is_level_beaten(levelData: LevelData) -> bool:
	return BeatenLevels.keys().has(levelData)

func is_better_level_score(levelData: LevelData, score: float) -> bool:
	if !is_level_beaten(levelData): return true
	return BeatenLevels[levelData] < score

func unlock_level(levelData: LevelData):
	if !is_level_unlocked(levelData): UnlockedLevels.append(levelData)

func beat_level(levelData: LevelData, score: float):
	if !is_level_unlocked(levelData): unlock_level(levelData)
	if is_better_level_score(levelData, score): BeatenLevels[levelData] = score
