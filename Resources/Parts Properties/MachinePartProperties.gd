class_name MachinePartProperties extends Resource

## Name that will be translated (required)
## example: "MP_B_1" short for MachinePart Battery 1 and will translate to Small Fuel/مخزن کوچک
@export var name := "MP_T_#"
## Mass (required),
## Force (optional),
## Joules stored (optional),
## Used Joules per second [J/s] (optional)
@export var properties_values := [ 10, 0, 0, 0 ]
## Texture for the game to display (required)
@export var texture : Texture2D = PlaceholderTexture2D.new()

func get_property(prop: int):
	return properties_values[prop]
