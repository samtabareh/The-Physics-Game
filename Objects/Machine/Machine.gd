class_name Machine extends RigidBody2D

const DEFAULT_PROPERTIES := {
	"mass": 10,
	"stored_joules": 0,
	"joules_usage": 0,
	"force": 0,
	"direction": Vector2(0, 0)
}

@export var connectors: Array[Connector]
@export var parts: Array[MachinePartProperties]
@export var base_mass: float = DEFAULT_PROPERTIES["mass"]
@export var properties := DEFAULT_PROPERTIES.duplicate()

var is_moving := false

func _ready():
	# Setup for connectors array
	var children = get_children()
	for child in children: if child is Connector:
		connectors.append(child)
		child.connection_changed.connect(connector_connection_changed)
		# Setup for any starting parts that are on the machine
		var properties = child.get_connected_part_properties()
		if properties: parts.append(properties)

func set_properties(props: Dictionary):
	# var old_props = properties.duplicate()
	
	for key in props.keys(): properties[key] = props[key]
	
	# For debugging the machine properties
	# print("-------\n", old_props, "\n", properties)

func connector_connection_changed(changed_connector: Connector, old_connector: Connector):
	var machine_props := DEFAULT_PROPERTIES.duplicate()
	for connector in connectors:
		var part_props: MachinePartProperties = connector.get_connected_part_properties()
		if !part_props: continue
		machine_props["mass"] += part_props.mass
		machine_props["stored_joules"] += part_props.stored_joules
		machine_props["joules_usage"] += part_props.joules_usage
		machine_props["force"] += part_props.force
		machine_props["direction"] += part_props.direction
	set_properties(machine_props)

func begin_movement():
	pass

func movement_tick():
	pass

func end_movement():
	pass
