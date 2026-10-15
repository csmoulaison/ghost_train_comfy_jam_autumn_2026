extends Area2D

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		CinematicState.start_cinematic(ID.Cinematic.INTRO_1, false)
		input_pickable = false
