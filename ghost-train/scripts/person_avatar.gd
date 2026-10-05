class_name PersonAvatar extends Node2D

@export var person_id: ID.Person
@export var at_destination_but_on_train: bool = false

@onready var sprite = get_node("Sprite2D")

func _ready():
	assert(sprite != null)
