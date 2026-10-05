extends Node

@export var current_location: ID.Location
@export var next_location: ID.Location
@export var current_road: ID.Road

func _ready():
	current_location = ID.Location.GRAVEYARD
	next_location = ID.Location.DEFAULT
	current_road = ID.Road.DEFAULT

func debug_text() -> String:
	var text: String = "Current location: " + ID.Location.keys()[current_location]
	text += "\nNext location: " + ID.Location.keys()[next_location]
	text += "\nCurrent Road: " + ID.Road.keys()[current_road]
	return text
