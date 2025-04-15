class_name DisplayText extends CanvasLayer

## Emitted when the player clicks on the box 
signal box_clicked
## Emitted when text() is called. value is the array of strings
signal writing_started(value)
## Emitted when moving from one text to another
signal writing_changed(value)
## Emitted when the text() is done writing.
signal writing_finished

const DEFAULT_SIZE = Vector2(1152, 225)

@onready var margin_container: MarginContainer = $MarginContainer
@onready var label: Label = $MarginContainer/MarginContainer/Label
@onready var player: AnimationPlayer = $MarginContainer/MarginContainer/Label/Player

var is_up: bool = false :
	set(v):
		if v: margin_container.set_anchors_preset(Control.PRESET_CENTER_TOP) 
		else: margin_container.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
		margin_container.size = DEFAULT_SIZE

func text(a : Array):
	writing_started.emit(a)
	for s in a:
		if !s is String or s == "": continue
		label.name = s
		show()
		player.play("RESET")
		player.play("Reveal", 1, clamp(s.length()/5, .5, 1.5))
		#if s.length() < 24: player.play("Reveal2")
		#else: player.play("Reveal3")
		await player.animation_finished
		await box_clicked
	hide()
	writing_finished.emit()

func _on_input(event):
	if Input.is_action_just_pressed("Click"):
		box_clicked.emit()
