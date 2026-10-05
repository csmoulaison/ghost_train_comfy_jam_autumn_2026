extends Node

var current_location: ID.Location
var next_location: ID.Location
var current_road: ID.Road

var passenger_car_count: int = 1
var cargo_car_count: int = 1
var passenger_slots: Array[ID.Person]

# TODO(now): we want an array of cars and an array of passengers in cars replacing
# GameState.people_on_train[]. assign passengers to a slot and they appear there.
# When boarding, need to check if passenger can even fit. NOTE: this means the
# dialogue state needs to have a dialogue line for if the passenger can't fit,
# which causes an immediate termination. I think maybe the state for all the 
# boarding dialogue stuff should live on the chain, not the line, and we force
# designers to only put these events at the end of dialogue chains.
const max_passenger_cars: int = 3
const max_passengers_per_car: int = 3

func _ready():
	current_location = ID.Location.GRAVEYARD
	next_location = ID.Location.DEFAULT
	current_road = ID.Road.DEFAULT
	passenger_slots.resize(max_passenger_cars * max_passengers_per_car)
	passenger_slots.fill(ID.Person.DEFAULT)

func try_board_passenger(person_id: ID.Person) -> bool:
	assert(ModeState.mode == ModeState.GameMode.DESTINATION, "Tried to board passenger, but not at a destination!")
	for index in passenger_car_count * max_passengers_per_car:
		if passenger_slots[index] == ID.Person.DEFAULT:
			GameState.people_locations[person_id] = ID.Location.DEFAULT
			passenger_slots[index] = person_id
			ModeState.update_train_avatars()
			ModeState.update_destination_avatars()
			return true
	return false

func offboard_passenger(person_id: ID.Person, location_id: ID.Location):
	assert(ModeState.mode == ModeState.GameMode.DESTINATION, "Tried to offboard passenger, but not at a destination!")
	for index in passenger_car_count * max_passengers_per_car:
		if passenger_slots[index] == person_id:
			passenger_slots[index] = ID.Person.DEFAULT
			GameState.people_locations[person_id] = location_id
			ModeState.update_train_avatars()
			ModeState.update_destination_avatars()
			return
	assert(false, "Offboarded passenger that wasn't on train!")

func person_on_train(id: ID.Person):
	for index in passenger_car_count * max_passengers_per_car:
		if passenger_slots[index] == id:
			return true
	return false

func debug_text() -> String:
	var text: String = "Current location: " + ID.Location.keys()[current_location]
	text += "\nNext location: " + ID.Location.keys()[next_location]
	text += "\nCurrent Road: " + ID.Road.keys()[current_road]
	return text
