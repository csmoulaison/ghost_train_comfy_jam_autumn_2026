extends Area2D

func _input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ModeState.load_destination_mode(TrainState.current_location)
		# TODO(now): We don't have a clean way of triggering the witch dialogue 
		# following this using our basic systems, so I think we just hardcode
		# the dialogue to start if the proper conditions are met.
