class_name Machine extends RigidBody2D

enum { MASS, FORCE, JOULES_STORED, JOULES_USAGE }

signal movement_start
signal movement_end
signal out_of_joules

const DEFAULT_PROPERTIES := [ MASS, FORCE, JOULES_STORED, JOULES_USAGE ]
const DEFAULT_VALUES := [ 10, 0, 0, 0 ]
const SPEED := 75
const JOULES_DISPLAY_COLORS := {
	75: Color8(0, 185, 47),
	50: Color8(208, 185, 47),
	25: Color8(208, 135, 47),
	0: Color8(208, 47, 47)
}

#region Exports
@export var wheels: Array[RigidBody2D]
@export var connectors: Array[Connector]
@export var camera: Camera2D
@export var base_mass: float = DEFAULT_VALUES[MASS]
@export var properties_values := DEFAULT_VALUES.duplicate()
#endregion

@onready var joules_display: ProgressBar = $JoulesDisplay
@onready var joules_text = $JoulesText

var max_joules: float = 0
var is_moving := false
var can_move: bool :
	get:
		return (get_property(JOULES_STORED) - get_property(JOULES_USAGE) >= 0 and
				get_property(JOULES_USAGE) != 0)

func _ready():
	# Setup for connectors array
	for child in get_children(): if child is Connector:
		connectors.append(child)
		child.connection_changed.connect(connector_connection_changed)
	
	var box := StyleBoxFlat.new()
	box.bg_color = JOULES_DISPLAY_COLORS[75]
	joules_display.theme.set_stylebox("fill", "ProgressBar", box)

func _input(event):
	if Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
		move(Input.get_axis("Left", "Right"))

func move(direction: float):
	if !is_moving: return
	# If it has no/not enough joules to use, trigger its signal and stop moving
	if !can_move:
		out_of_joules.emit()
		end_movement()
		return
	
	for wheel in wheels:
		wheel.apply_force(Vector2(
		(get_property(FORCE) + get_property(MASS)) / 2 * SPEED * direction, 0))
		
	# Decrease joules stored
	set_properties([JOULES_STORED], [-get_property(JOULES_USAGE)/4], true)
	
	# Update the joules displays
	joules_display.value = get_property(JOULES_STORED)
	joules_text.text = str(get_property(JOULES_STORED))
	
	for key in JOULES_DISPLAY_COLORS.keys():
		var ratio = get_property(JOULES_STORED) / max_joules * 100
		
		if ratio >= key:
			var box := StyleBoxFlat.new()
			box.bg_color = JOULES_DISPLAY_COLORS[key]
			
			joules_display.theme.set_stylebox("fill", "ProgressBar", box)
			break

func connector_connection_changed(changed_connector: Connector, old_connector: Connector):
	if is_moving: return
	
	var props_values := DEFAULT_VALUES.duplicate()
	for connector in connectors:
		var part_props: MachinePartProperties = connector.get_connected_part_properties()
		
		if !part_props: continue
		for prop in DEFAULT_PROPERTIES:
			props_values[prop] += part_props.get_property(prop)
	
	set_properties(DEFAULT_PROPERTIES, props_values)
	
	max_joules = get_property(JOULES_STORED)
	
	# Update the joules displays
	joules_display.max_value = max_joules
	joules_display.value = get_property(JOULES_STORED)
	joules_text.text = str(get_property(JOULES_STORED))
	joules_display.step = get_property(JOULES_USAGE)

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
	# To prevent people from starting with no joules stored
	if !can_move: return
	
	movement_start.emit()
	# Wait for camera to zoom on machine
	await get_tree().create_timer(1).timeout
	is_moving = true

func end_movement():
	movement_end.emit()
	is_moving = false
