extends Node

@export var current_or_next_location: ID.Location

func _ready() -> void:
	current_or_next_location = ID.Location.GRAVEYARD
