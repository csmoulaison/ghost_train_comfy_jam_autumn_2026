extends Control

@onready var yes_button: Button = get_node("Panel/HBoxContainer/TravelConfirmationYes")
@onready var no_button: Button = get_node("Panel/HBoxContainer/TravelConfirmationNo")
@onready var label: Label = get_node("Panel/Label")

func _ready():
	assert(yes_button != null)
	assert(no_button != null)
	assert(label != null)
	yes_button.pressed.connect(on_yes)
	no_button.pressed.connect(on_no)

func on_yes():
	ModeState.depart_to_travel()

func on_no():
	TrainState.next_location = ID.Location.DEFAULT
	TrainState.current_road = ID.Road.DEFAULT
	MapState.init_visual_state()
