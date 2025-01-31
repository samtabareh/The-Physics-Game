class_name MachinePartProperties extends Resource

@export_subgroup("Physics")
## Name that will be translated (required)
## example: "MP_B_1" short for MachinePart Battery 1 and will translate to Small Fuel/مخزن کوچک
@export var name := "MP_T_#"
## Mass (required)
@export var mass := 10.0
## Stored joules (optional)
@export var stored_joules: float
## Used Joules per second [J/s] (optional)
@export var joules_usage: float
## Amount of force to do (optional)
@export var force : float
## Direction of force (optional)
@export var direction : Vector2

@export_subgroup("Other")
## Texture for the game to display (required)
@export var texture : Texture2D = PlaceholderTexture2D.new()
