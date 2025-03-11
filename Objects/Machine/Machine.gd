class_name Machine extends RigidBody2D

enum { MASS, FORCE, JOULES_STORED, JOULES_USAGE }

signal movement_start
signal movement_end

const DEFAULT_PROPERTIES := [ MASS, FORCE, JOULES_STORED, JOULES_USAGE ]
const DEFAULT_VALUES := [ 10, 0, 0, 0 ]
const SPEED := 75

#region Exports
@export var wheels: Array[RigidBody2D]
@export var connectors: Array[Connector]
@export var camera: Camera2D
@export var base_mass: float = DEFAULT_VALUES[MASS]
@export var properties_values := DEFAULT_VALUES.duplicate()
#endregion

var is_moving := false

func _ready():
	# Setup for connectors array
	for child in get_children(): if child is Connector:
		connectors.append(child)
		child.connection_changed.connect(connector_connection_changed)
	

func _input(event):
	if Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
		move(Input.get_axis("Left", "Right"))

func move(direction: float):
	if !is_moving: return
	if get_property(JOULES_STORED) - get_property(JOULES_USAGE) < 0 or get_property(JOULES_USAGE) == 0: return
	
	for wheel in wheels:
		wheel.apply_force(Vector2(
		(get_property(FORCE) + get_property(MASS)) / 2 * SPEED * direction, 0))
		
	# Decrease joules stored
	set_properties([JOULES_STORED], [-get_property(JOULES_USAGE)/4], true)

func connector_connection_changed(changed_connector: Connector, old_connector: Connector):
	if is_moving: return
	
	var props_values := DEFAULT_VALUES.duplicate()
	for connector in connectors:
		var part_props: MachinePartProperties = connector.get_connected_part_properties()
		
		if !part_props: continue
		for prop in DEFAULT_PROPERTIES:
			props_values[prop] += part_props.get_property(prop)
	
	set_properties(DEFAULT_PROPERTIES, props_values)

#region Properties
func set_properties(props: Array, values: Array, add: bool = false):
	if props.size() != values.size(): push_error("The properties_values array and values array do not match")
	var i = 0
	for prop in props:
		if add: properties_values[prop] += values[i]
		else: properties_values[prop] = values[i]
		i += 1

func get_property(prop: int):
	return properties_values[prop]

func get_property_name(prop: int, case := 0) -> String:
	if prop == MASS: return "mass" if case == -1 else "Mass" if case == 0 else "MASS"
	elif prop == FORCE: return "force" if case == -1 else "Force" if case == 0 else "FORCE"
	elif prop == JOULES_STORED: return "joules stored" if case == -1 else "Joules Stored" if case == 0 else "JOULES STORED"
	elif prop == JOULES_USAGE: return "joules usage" if case == -1 else "Joules Usage" if case == 0 else "JOULES USAGE"
	else: return ""
#endregion

func start_movement():
	movement_start.emit()
	# Wait for camera to zoom on machine
	await get_tree().create_timer(1).timeout
	is_moving = true

func end_movement():
	is_moving = false
