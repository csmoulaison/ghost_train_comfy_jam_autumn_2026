extends Area2D

@export var post_track_dialogue: DialogueLine

@onready var sprite = get_node("Sprite2D")

func _ready():
	assert(post_track_dialogue != null)
	assert(sprite != null)
	
func _process(_dt):
	if MapState.buying_tracks and GameState.flags[ID.Flag.FIRST_TRACK_BOUGHT]:
		sprite.modulate.a = 1.0
		input_pickable = true
	else:
		sprite.modulate.a = 0.0
		input_pickable = false

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ModeState.load_destination_mode(TrainState.current_location)
		if MapState.buying_tracks:
			if !GameState.flags[ID.Flag.FIRST_TRACK_BOUGHT]:
				assert(false, "Exit button shouldn't be active if you haven't boiyught witch tracl and AASHJ!!!")
			else:
				DialogueState.open_dialogue([], post_track_dialogue)
