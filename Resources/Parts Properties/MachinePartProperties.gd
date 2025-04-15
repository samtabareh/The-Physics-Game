class_name MachinePartProperties extends Resource

## Name that will be translated (required)
## example: "MP_B_1" short for MachinePart Battery 1 and will translate to Small Tank/مخزن کوچک
@export var name := "MP_T_#"
## [0] = Mass* [br]
## [1] = Force [br]
## [2] = Joules stored [br]
## [3] = Used Joules per second [J/s]
@export var properties_values: Array = [ 10, 0, 0, 0 ]
## Texture for the game to display (required)
@export var texture : Texture2D

func get_property(prop: int):
	return properties_values[prop]

static func get_property_name(prop: int, case := 0, underscored := false) -> String:
	var ret: String = ""
	if prop == 0: ret = "mass" if case == -1 else "Mass" if case == 0 else "MASS"
	elif prop == 1: ret = "force" if case == -1 else "Force" if case == 0 else "FORCE"
	if underscored:
		if prop == 2: ret = "joules_stored" if case == -1 else "Joules_Stored" if case == 0 else "JOULES_STORED"
		elif prop == 3: ret = "joules_usage" if case == -1 else "Joules_Usage" if case == 0 else "JOULES_USAGE"
	else:
		if prop == 2: ret = "joules stored" if case == -1 else "Joules Stored" if case == 0 else "JOULES STORED"
		elif prop == 3: ret = "joules usage" if case == -1 else "Joules Usage" if case == 0 else "JOULES USAGE"
	return ret
