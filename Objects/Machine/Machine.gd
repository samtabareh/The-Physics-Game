class_name Machine extends RigidBody2D

signal movement_start
signal movement_tick(delta)
signal movement_end

enum { MASS, FORCE, JOULES_STORED, JOULES_USAGE }

const DEFAULT_PROPERTIES := [ MASS, FORCE, JOULES_STORED, JOULES_USAGE ]
const DEFAULT_VALUES := [ 10, 0, 0, 0 ]
const SPEED := 15

@export var wheels: Array[RigidBody2D]
@export var connectors: Array[Connector]
@export var parts: Array[MachinePartProperties]
@export var camera: Camera2D
@export var base_mass: float = DEFAULT_VALUES[MASS]
@export var properties_values := DEFAULT_VALUES.duplicate()

var is_moving := false :
	set(value):
		for wheel: RigidBody2D in wheels: wheel.sleeping = !value
		is_moving = value

func _ready():
	# Setup for connectors array
	var children = get_children()
	for child in children: if child is Connector:
		connectors.append(child)
		child.connection_changed.connect(connector_connection_changed)
		# Setup for any starting parts that are on the machine
		var part_props = child.get_connected_part_properties()
		if part_props: parts.append(part_props)

func set_properties(props: Array, values: Array, add: bool = false):
	if props.size() != values.size(): push_error("The properties_values array and values array do not match")
	var i = 0
	for prop in props:
		if add: properties_values[prop] += values[i]
		else: properties_values[prop] = values[i]
		i += 1

func get_property(prop: int):
	return properties_values[prop]

func connector_connection_changed(changed_connector: Connector, old_connector: Connector):
	if is_moving: return
	
	var props_values := DEFAULT_VALUES.duplicate()
	for connector in connectors:
		var part_props: MachinePartProperties = connector.get_connected_part_properties()
		if !part_props: continue
		for prop in DEFAULT_PROPERTIES: props_values[prop] += part_props.get_property(prop)
	set_properties(DEFAULT_PROPERTIES, props_values)

func start_movement():
	movement_start.emit()
	# Wait for camera to zoom on machine
	await get_tree().create_timer(1).timeout
	is_moving = true

func _physics_process(delta):
	if !is_moving: return
	if get_property(JOULES_STORED) - get_property(JOULES_USAGE) >= 0 and get_property(JOULES_USAGE) != 0:
		# rotate the wheels
		for wheel in wheels: wheel.apply_torque_impulse(
			(get_property(FORCE) + get_property(MASS)) / 2 * SPEED * delta * 60)
		# Decrease joules stored
		set_properties([JOULES_STORED], [-get_property(JOULES_USAGE)], true)
		movement_tick.emit(delta)
	else: end_movement()

func end_movement():
	is_moving = false
	movement_end.emit()
