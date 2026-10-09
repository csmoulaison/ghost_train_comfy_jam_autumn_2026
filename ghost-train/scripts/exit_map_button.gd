extends Area2D

@export var post_track_dialogue_tutorial: DialogueLine
@export var post_track_dialogue_normal: DialogueLine

func _ready():
	assert(post_track_dialogue_tutorial != null)
	assert(post_track_dialogue_normal != null)

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		ModeState.load_destination_mode(TrainState.current_location)
		if MapState.buying_tracks:
			if !GameState.flags[ID.Flag.FIRST_TRACK_BOUGHT]:
				assert(MapState.roads_unlocked[ID.Road.FARMERS_MARKET_TO_WITCHS_TRAIN_YARD], "Player shouldn't be allowed to leave the track buying map the first time without buying the road to the witch's trainyard.")
				GameState.flags[ID.Flag.FIRST_TRACK_BOUGHT] = true
				DialogueState.open_dialogue([], post_track_dialogue_tutorial)
			else:
				DialogueState.open_dialogue([], post_track_dialogue_normal)
