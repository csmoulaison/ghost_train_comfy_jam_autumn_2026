extends Node

@onready var debug_label: Label = get_tree().current_scene.find_child("DebugOverlayLabel")

func _ready():
	assert(debug_label != null)

func _process(dt: float):
	debug_label.text = ""
	output_debug_label_line(ModeState.debug_text())
	output_debug_label_line(TrainState.debug_text())
	output_debug_label_line(MoneyState.debug_text())
	
func output_debug_label_line(text: String):
	debug_label.text += text + "\n"
