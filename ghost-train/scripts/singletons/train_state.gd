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

func board_passenger(person_id: ID.Person):
	assert(ModeState.mode == ModeState.GameMode.DESTINATION, "Tried to board passenger, but not at a destination!")
	GameState.people_locations[person_id] = ID.Location.DEFAULT
	GameState.people_on_train[person_id] = true
	ModeState.update_scene_avatars(ModeState.loaded_scene_instance)

func offboard_passenger(person_id: ID.Person, location_id: ID.Location):
	assert(ModeState.mode == ModeState.GameMode.DESTINATION, "Tried to offboard passenger, but not at a destination!")
	GameState.people_locations[person_id] = location_id
	GameState.people_on_train[person_id] = false
	ModeState.update_scene_avatars(ModeState.loaded_scene_instance)
