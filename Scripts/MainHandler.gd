extends BaseHandler

const PART_PROP_RES_PATH := "res://Resources/Parts Properties/"
const PART_NAME_MAP := {
	"B": "Battery",
	"F": "Force"
}

var mm_coins: int = 0
var machine_scraps: int = 0

var is_dev := false :
	set(value):
		is_dev = value
		print_as("is_dev: %s" % is_dev)
var is_android: bool :
	get:
		return OS.get_name() == "Android"
var unlocked_parts: Array[MachinePartProperties] = []
var unlocked_skins: Array = []

@onready var open_collection: Collection

func give_mm_coins(amount: int):
	mm_coins += amount
	print_as("Gave %s Machine Maker coins to player" % amount)
	SaveHandler.save_game()

func unlock_skin(skin):
	if !unlocked_skins.has(skin): unlocked_skins.append(skin)

func unlock_part(part: MachinePartProperties):
	if !unlocked_parts.has(part): unlocked_parts.append(part)

func get_part_prop_from_name(key: String) -> MachinePartProperties:
	if key == "": return
	
	# Example 'key' : "MP_B_1"
	var type = key.split("_").slice(1, 3)
	var num = type[1]
	type = type[0]
	
	# Example 'file_name' : "Battery1.tres"
	var file_name = PART_NAME_MAP[type] + num + ".tres"
	var full_path = PART_PROP_RES_PATH + file_name
	var part: MachinePartProperties = load(full_path)
	return part

func get_part_file_name_from_part(part, include_ext: bool = false) -> String:
	var key
	
	if part is String: key = part
	elif part is MachinePart: key = part.properties.name
	elif part is MachinePartProperties: key = part.name
	else: return ""
	
	# Example 'key' : "MP_B_1"
	var type = key.split("_").slice(1, 3)
	var num = type[1]
	type = type[0]
	
	# Example 'file_name' : "Battery1"
	var file_name = PART_NAME_MAP[type] + num if !include_ext else PART_NAME_MAP[type] + num + ".tres"
	return file_name

func exit():
	await SaveHandler.save_game()
	get_tree().quit()
