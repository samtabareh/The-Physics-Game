class_name Connector extends Node2D

signal connection_changed(connector, old_connector)

## The Connector that this has connected to (null if not connected)
var connected_to_connector: Connector = null
var is_connected_to_connector: bool
## If the connector can change its connection
@export var can_connect := true
## True if its a part of a machine, False if its a part of a MachinePart
var is_machine: bool :
	get: return parent is Machine
@onready var parent = get_parent()
var picked_up: bool = false

func _process(delta):
	if !is_machine:
		picked_up = parent.picked_up
		
		if is_connected_to_connector and !picked_up:
			# Set rotations and positions for the part connector
			if connected_to_connector.rotation != 0:
				parent.rotation = -connected_to_connector.rotation
				parent.position = connected_to_connector.global_position
				parent.position.y += connected_to_connector.global_position.y - global_position.y
				parent.position.x += connected_to_connector.global_position.x - global_position.x
				
			else:
				parent.position = connected_to_connector.global_position - position
		elif !is_connected_to_connector and picked_up: parent.rotation = 0

func set_connection(connector: Connector):
	if connected_to_connector == connector: return
	
	var old_connector = connected_to_connector
	
	is_connected_to_connector = connector != null
	connected_to_connector = connector
	
	connection_changed.emit(self, old_connector)

func get_connected_part_properties() -> MachinePartProperties:
	if is_machine:
		# If this connector isnt connected to anything, return nothing
		if !is_connected_to_connector: return null
		# If this connector is connected to a part, call the connector of the part
		else: return connected_to_connector.get_connected_part_properties()
	
	# There is no need for an else here because all routes in the if are returns
	return parent.properties

func _on_area_entered(area: Area2D):
	if is_connected_to_connector: return
	var par = area.get_parent()
	# Check if there is a parent (to avoid crashes) and
	# if the collision is from another Connector and
	# if the other Connector's parent is the reverse of ours (will accept if 
	if par and par is Connector and par.is_machine != is_machine: set_connection(par)

func _on_area_exited(area: Area2D):
	if !is_connected_to_connector: return
	var par = area.get_parent()
	# Check if there is a parent (to avoid crashes) and
	# if the exited Connector is our connected to Connector
	if par and par == connected_to_connector: set_connection(null)
