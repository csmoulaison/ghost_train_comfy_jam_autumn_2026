extends Control

@onready var yes_button: Button = get_node("Panel/HBoxContainer/TravelConfirmationYes")
@onready var no_button: Button = get_node("Panel/HBoxContainer/TravelConfirmationNo")

func _ready():
	yes_button.pressed.connect(on_yes)
	no_button.pressed.connect(on_no)

func on_yes():
	ModeState.depart_to_travel()

func on_no():
	TrainState.next_location = ID.Location.DEFAULT
	TrainState.current_road = ID.Road.DEFAULT
	MapState.init_visual_state()
