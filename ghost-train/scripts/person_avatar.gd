class_name PersonAvatar extends Node2D

@export var person_id: ID.Person

@onready var sprite = get_node("Sprite2D")
@onready var interactable: Interactable = get_node("Interactable")

func _ready():
	assert(sprite != null)
	assert(interactable != null)
	interactable.interacted.connect(_on_interacted)

func _on_interacted():
	var person: Person = ResourceData.people[person_id]
	if person.default_dialogue_chain != null:
		DialogueState.start_dialogue(person.default_dialogue_chain)
		return

	# TODO: Delete this functionality, it's just a temporary stand in for what will
	# eventually be triggered mroe explicitly by DialogueLine data.
	# Only runs for people with no dialogue chain yet.
	if ModeState.mode == ModeState.GameMode.DESTINATION and !TrainState.person_on_train(person_id):
		TrainState.try_board_passenger(person_id)
