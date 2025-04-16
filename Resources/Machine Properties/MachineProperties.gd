class_name MachineProperties extends Node

enum {
	MASS,
	JOULES_STORED,
	FORCE,
	FORCE_JOULES_USAGE,
	JUMP,
	JUMP_JOULES_USAGE
}

const DEFAULT_MACHINE_PROPERTIES: Dictionary = {
	MASS: 10,
	JOULES_STORED: 0,
	FORCE: 0,
	FORCE_JOULES_USAGE: 0,
	JUMP: 0,
	JUMP_JOULES_USAGE: 0
}

var properties := DEFAULT_MACHINE_PROPERTIES.duplicate()

static func get_property_name(prop: int,
	capitalized := true,
	under_case := true ) -> String:
	var ret := ""
	
	if prop == MASS: ret = "mass"
	elif prop == JOULES_STORED: ret = "joules stored"
	elif prop == FORCE: ret = "force"
	elif prop == FORCE_JOULES_USAGE: ret = "force joules usage"
	elif prop == JUMP: ret = "jump"
	elif prop == JUMP_JOULES_USAGE: ret = "jump joules usage"
	
	if capitalized: ret = ret.capitalize()
	if under_case: ret = ret.replace(" ", "_")
	
	return ret

func set_properties(props: Dictionary, add: bool = false):
	for prop in props.keys():
		if add: properties[prop] += props[prop]
		else: properties[prop] = props[prop]

func get_property(prop: int):
	return properties.get(prop)
