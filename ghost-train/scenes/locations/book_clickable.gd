extends Area2D

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		TrainState.small_cargo_on_train[ID.SmallCargo.BOOK] = true
