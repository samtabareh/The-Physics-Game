class_name MachinePartProperties extends Resource

## Name that will be translated
@export var name := "MP_T_#"
## Texture for the game to display
@export var sprite_frames: SpriteFrames
## [0] = Mass* [br]
## [1] = Joules Stored [br]
## [2] = Force [br]
## [3] = Force Joules Usage [br]
## [4] = Jump [br]
## [5] = Jump Joules Usage
@export var properties := MachineProperties.DEFAULT_MACHINE_PROPERTIES

func get_property(prop: int):
	return properties[prop]
