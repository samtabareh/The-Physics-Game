class_name Connector extends Node2D

signal connection_changed(connector, old_connector)

@onready var parent :
	get:
		return get_parent()

var queued_connections: Array[Connector] = []
## The Connector that this has connected to | null if not connected
var connected_to_connector: Connector = null
## Is the connector a part of a machine
var is_machine: bool :
	get: return parent is Machine
## Is connected
var is_connected_to_connector: bool :
	get:
		return connected_to_connector != null
## (If it's a part's' connector, else it's false) Is it picked up
var picked_up: bool :
	get:
		return parent.picked_up if !is_machine else false

func _process(delta):
	if !is_machine:
		if !queued_connections.is_empty() and (!picked_up or queued_connections[-1] == null):
			set_connection(queued_connections[-1])
			queued_connections = []
		
		if !picked_up and is_connected_to_connector:
			# Set rotations and positions for the part connector
			if connected_to_connector.rotation != 0:
				parent.rotation = -connected_to_connector.rotation
				parent.position = connected_to_connector.global_position
				parent.position.y += connected_to_connector.global_position.y - global_position.y
				parent.position.x += connected_to_connector.global_position.x - global_position.x
			else: parent.position = connected_to_connector.global_position - position
		# Reset part rotation
		elif !is_connected_to_connector and picked_up: parent.rotation = 0
	else:
		if !queued_connections.is_empty() and queued_connections[-1] == null: set_connection(null)

## Sets the connector's connection (returns true if successful)
func set_connection(connector: Connector) -> bool:
	if (connector and connector.is_connected_to_connector) or connected_to_connector == connector: return false
	
	var old_connector = connected_to_connector
	
	# tell the machine connector that its connecting
	if !is_machine and connector:
		# If machine connected, then connect
		if connector.set_connection(self): connected_to_connector = connector
		else: return false
	else: connected_to_connector = connector
	
	connection_changed.emit(self, old_connector)
	return true

func queue_connection(connector: Connector):
	if connected_to_connector == connector: return
	queued_connections.append(connector)

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
	# if the other Connector's parent is the reverse of ours
	# and if the other connector isnt connected to anything
	if par and par is Connector and par.is_machine != is_machine and !par.is_connected_to_connector:
		queue_connection(par)

func _on_area_exited(area: Area2D):
	if !is_connected_to_connector: return
	var par = area.get_parent()
	# Check if there is a parent (to avoid crashes) and
	# if the exited Connector is our connected to Connector
	if par and par == connected_to_connector: queue_connection(null)
