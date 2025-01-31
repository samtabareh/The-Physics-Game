class_name LevelData extends Resource

@export var Id : int
@export var Name : String
@export var Category : String
@export var Path : String

static func LevelData(id: int, name: String, category: String, path: String):
	var leveldata = LevelData.new()
	leveldata.Id = id
	leveldata.Name = name
	leveldata.Category = category
	leveldata.Path = path
	return leveldata
