extends Node

@onready var debug_control: Node = get_tree().current_scene.get_node("DebugOverlay/Control")
@onready var debug_label: Label = get_tree().current_scene.find_child("DebugOverlayLabel")

var active: bool = false

func _ready():
	assert(debug_label != null)
	assert(debug_control != null)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_overlay"): active = !active

func _process(_dt: float):
	debug_control.modulate.a = 1.0 if active else 0.0
	debug_label.text = ""
	output_debug_label_line(ModeState.debug_text())
	output_debug_label_line(TrainState.debug_text())
	output_debug_label_line(MoneyState.debug_text())
	output_debug_label_line(GameState.debug_text())
	output_debug_label_line(CinematicState.debug_text())
	
func output_debug_label_line(text: String):
	debug_label.text += text + "\n"
