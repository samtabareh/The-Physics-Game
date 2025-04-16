class_name Machine extends RigidBody2D

signal movement_start
signal movement_end

## Multiplier for movement
const SPEED := 75
## Multiplier for jump
const JUMP_SPEED := 10000
## Colors shown on "Joules Display" sorted based on percentage left
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
@export var machine_properties := MachineProperties.new()
#endregion

@onready var joules_display: ProgressBar = $JoulesDisplay
@onready var joules_text: Label = $JoulesDisplay/JoulesText

var max_joules: float = 0
var is_moving := false
## Joules stored - Force joules usage more or equal to 0 and Force joules usage is not 0
var can_move: bool :
	get:
		return (
			(machine_properties.get_property(MachineProperties.JOULES_STORED)
			- machine_properties.get_property(MachineProperties.FORCE_JOULES_USAGE) >= 0 and
			machine_properties.get_property(MachineProperties.FORCE_JOULES_USAGE) != 0)
			)
## Joules stored - Jump joules usage more or equal to 0 and Jump joules usage is not 0
var can_jump: bool :
	get:
		return ((machine_properties.get_property(MachineProperties.JOULES_STORED)
			- machine_properties.get_property(MachineProperties.JUMP_JOULES_USAGE)) >= 0 and
			machine_properties.get_property(MachineProperties.JUMP_JOULES_USAGE) != 0)

func _ready():
	# Setup for connectors array
	for child in get_children(): if child is Connector:
		connectors.append(child)
		child.connection_changed.connect(connector_connection_changed)
	
	var box := StyleBoxFlat.new()
	box.set_corner_radius_all(6)
	box.bg_color = JOULES_DISPLAY_COLORS[0]
	joules_display.theme.set_stylebox("fill", "ProgressBar", box)

func _input(event):
	if Input.is_action_pressed("Left") or Input.is_action_pressed("Right"):
		move(Input.get_axis("Left", "Right"))
	if Input.is_action_just_pressed("Up") or (event is InputEventMouseButton and event.double_click):
		jump()

func move(direction: float):
	if !is_moving: return
	# If not enough joules to move, end movement
	if !can_move:
		end_movement()
		return
	
	for wheel in wheels:
		wheel.apply_force(Vector2(
		(machine_properties.get_property(MachineProperties.FORCE) + machine_properties.get_property(MachineProperties.MASS)) / 2 * SPEED * direction, 0))
		
	# Add the negative joules usage to joules stored
	machine_properties.set_properties({MachineProperties.JOULES_STORED: -machine_properties.get_property(MachineProperties.FORCE_JOULES_USAGE)/4}, true)
	
	# Update the joules displays
	update_displays()

func jump():
	if !is_moving or !can_jump: return
	
	#apply_central_force(Vector2(0, machine_properties.get_property(MachineProperties.JUMP) * JUMP_SPEED))
		
	# Add the negative joules usage to joules stored
	#machine_properties.set_properties({MachineProperties.JOULES_STORED: -machine_properties.get_property(MachineProperties.JUMP_JOULES_USAGE)}, true)
	
	update_displays()

func start_movement():
	# To prevent starting with no joules stored or no motor
	if !can_move: return
	
	movement_start.emit()
	# Wait for camera to zoom on machine
	await get_tree().create_timer(1).timeout
	is_moving = true

func end_movement():
	is_moving = false
	movement_end.emit()

func connector_connection_changed(changed_connector: Connector, old_connector: Connector):
	if is_moving: return
	
	var old_props := machine_properties.properties.duplicate()
	
	var props := MachineProperties.DEFAULT_MACHINE_PROPERTIES.duplicate()
	for connector in connectors:
		var part_props: MachinePartProperties = connector.get_connected_part_properties()
		
		if !part_props: continue
		for prop in MachineProperties.DEFAULT_MACHINE_PROPERTIES:
			props[prop] += part_props.get_property(prop)
	
	machine_properties.set_properties(props)
	
	max_joules = machine_properties.get_property(MachineProperties.JOULES_STORED)
	
	if max_joules != old_props[MachineProperties.JOULES_STORED]:
		# Update the joules displays
		
		# Update box theme
		var box := StyleBoxFlat.new()
		box.set_corner_radius_all(6)
		# If no tank, make the box color red
		if max_joules == 0: box.bg_color = JOULES_DISPLAY_COLORS[0]
		else: box.bg_color = JOULES_DISPLAY_COLORS[75]
		joules_display.theme.set_stylebox("fill", "ProgressBar", box)
		
		# Update text
		joules_display.max_value = max_joules
		joules_display.value = machine_properties.get_property(MachineProperties.JOULES_STORED)
		joules_display.step = machine_properties.get_property(MachineProperties.FORCE_JOULES_USAGE)
		
		joules_text.text = str(machine_properties.get_property(MachineProperties.JOULES_STORED))

func update_displays():
	joules_display.value = machine_properties.get_property(MachineProperties.JOULES_STORED)
	joules_text.text = str(machine_properties.get_property(MachineProperties.JOULES_STORED))
	
	var box := StyleBoxFlat.new()
	box.set_corner_radius_all(6)
	for key in JOULES_DISPLAY_COLORS.keys():
		var ratio = machine_properties.get_property(MachineProperties.JOULES_STORED) / max_joules * 100
		if ratio >= key:
			box.bg_color = JOULES_DISPLAY_COLORS[key]
			break
	joules_display.theme.set_stylebox("fill", "ProgressBar", box)
