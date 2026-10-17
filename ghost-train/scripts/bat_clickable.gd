extends Area2D

func _ready():
	Cursor.define_hover(self, Cursor.Type.POINT)

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		GameState.flags[ID.Flag.BAT_TURNED_INTO_VAMPIRE] = true
