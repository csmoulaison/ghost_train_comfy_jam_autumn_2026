extends Node2D

@onready var interactable: Interactable = get_node("Locomotive/Interactable")

func _ready():
	assert(interactable != null)
	interactable.interacted.connect(_on_interacted)
	
func _process(dt: float):
	match ModeState.mode:
		ModeState.GameMode.DESTINATION:
			interactable.prompt_text = "Depart"
		ModeState.GameMode.TRAVEL:
			interactable.prompt_text = "Arrive"

func _on_interacted():
	match ModeState.mode:
		ModeState.GameMode.DESTINATION:
			ModeState.enter_map_mode(false)
		ModeState.GameMode.TRAVEL:
			ModeState.arrive_at_destination(TrainState.next_location)
		_:
			assert(false, "Interacted with train avatar, not in destination or travel mode?")
