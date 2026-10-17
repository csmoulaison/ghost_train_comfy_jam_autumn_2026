extends CanvasLayer

@onready var label = get_node("Label")

var timer: float = 0.0
var controls_fired: bool = false
var depart_fired: bool = false
var arrive_fired: bool = false
var controls_alpha = 0.0
var depart_alpha = 0.0
var arrive_alpha = 0.0

func _process(dt: float) -> void:
	label.modulate.a = move_toward(label.modulate.a, max(controls_alpha, depart_alpha, arrive_alpha), dt * 1.0)
	
	timer -= dt
	if timer < 0.0:
		controls_alpha = 0.0
		depart_alpha = 0.0
		arrive_alpha = 0.0
	if !controls_fired and !ModeState.control_paused() and ModeState.mode == ModeState.GameMode.DESTINATION:
		controls_fired = true
		controls_alpha = 1.0
		label.text = "Click or use [A/D] and [Space] to move and interact."
		timer = 8.0
	if controls_fired and DialogueState.is_active():
		controls_alpha = 0.0
		
	if !depart_fired:
		if ModeState.mode == ModeState.GameMode.TRAVEL:
			depart_fired = true
		else: if !ModeState.control_paused() and TrainState.cargo_on_train(ID.Cargo.PUMPKINS):
			depart_fired = true
			depart_alpha = 1.0
			label.text = "Click the train's locomotive to depart."
			timer = 6.0
	if depart_fired and (CinematicState.current_cinematic == ID.Cinematic.DEPART_TO_TRAVEL or ModeState.mode == ModeState.GameMode.MAP):
		depart_alpha = 0.0
	
	if !arrive_fired and ModeState.mode == ModeState.GameMode.TRAVEL:
		arrive_fired = true
		arrive_alpha = 1.0
		label.text = "Explore the train. Click the locomotive to finish the ride."
		timer = 8.0
	if arrive_fired and (ModeState.mode != ModeState.GameMode.TRAVEL or DialogueState.is_active()):
		arrive_alpha = 0.0
