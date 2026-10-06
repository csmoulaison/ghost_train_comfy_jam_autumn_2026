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
	DialogueState.open_dialogue(person.conditional_interact_dialogue, person.default_interact_dialogue)
