class_name PersonAvatar extends Node2D

@export var person_id: ID.Person

@onready var sprite = get_node("Sprite2D")
@onready var area = get_node("Area2D")

func _ready():
	assert(sprite != null)
	assert(area != null)
	area.input_event.connect(click)

# TODO: Choose what dialogue to trigger explicitly.
func click(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if ModeState.mode == ModeState.GameMode.DESTINATION and !TrainState.person_on_train(person_id):
			#TrainState.try_board_passenger(person_id)
			DialogueState.start_dialogue(ResourceData.people[person_id].default_dialogue_chain)
