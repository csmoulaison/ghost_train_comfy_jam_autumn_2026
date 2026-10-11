extends Node2D

@onready var interactable: Interactable = get_node("Locomotive/Interactable")

func _ready():
	assert(interactable != null)
	interactable.interacted.connect(_on_interacted)
	interactable.input_event.connect(_on_input_event)
	
func _process(dt: float):
	match ModeState.mode:
		ModeState.GameMode.DESTINATION:
			interactable.interaction_active = false
			interactable.prompt_text = "Depart"
		ModeState.GameMode.TRAVEL:
			interactable.interaction_active = true
			interactable.prompt_text = "Arrive"

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if !ModeState.control_paused() and ModeState.GameMode.DESTINATION:
			ModeState.enter_map_mode(false)

# TODO(now): stop interaction if we haven't boarded the crow initially. use a flag
func _on_interacted():
	match ModeState.mode:
		ModeState.GameMode.DESTINATION:
			pass
			#ModeState.enter_map_mode(false)
		ModeState.GameMode.TRAVEL:
			ModeState.arrive_at_destination(TrainState.next_location)
		_:
			assert(false, "Interacted with train avatar, not in destination or travel mode?")
