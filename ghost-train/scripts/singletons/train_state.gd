extends Node

var current_location: ID.Location
var next_location: ID.Location
var current_road: ID.Road

var passenger_car_count: int = 1
var cargo_car_count: int = 1
var passenger_slots: Array[ID.Person]
var cargo_slots: Array[ID.Cargo]
var small_cargo_on_train: Array[ID.SmallCargo]

const max_cargo_cars: int = 3
const max_passenger_cars: int = 3
const max_passengers_per_car: int = 2

func _ready():
	current_location = ID.Location.GRAVEYARD
	next_location = ID.Location.DEFAULT
	current_road = ID.Road.DEFAULT
	passenger_slots.resize(max_passenger_cars * max_passengers_per_car)
	passenger_slots.fill(ID.Person.DEFAULT)
	cargo_slots.resize(max_cargo_cars)
	cargo_slots.fill(ID.Cargo.DEFAULT)
	small_cargo_on_train.resize(ID.SmallCargo.SMALL_CARGO_COUNT)
	small_cargo_on_train.fill(ID.SmallCargo.DEFAULT)

func try_load_cargo(cargo_id: ID.Cargo) -> bool:
	print("try load")
	assert(ModeState.mode == ModeState.GameMode.DESTINATION, "Tried to load cargo, but not at destination!")
	var slot: int = next_available_cargo_slot()
	if slot != -1:
		print("loading it")
		cargo_slots[slot] = cargo_id
		ModeState.update_train_avatars(false)
		return true
	return false

func sell_cargo(cargo_id: ID.Cargo):
	var cargo: Cargo = ResourceData.cargos[cargo_id]
	for slot in cargo_slots:
		if slot == cargo_id:
			cargo_slots[slot] = ID.Cargo.DEFAULT
			MoneyState.add_coins(cargo.revenue)
			ModeState.update_train_avatars(false)
			return
	assert(false, "Tried to sell cargo that we didn't have!")

func try_board_passenger(person_id: ID.Person) -> bool:
	assert(ModeState.mode == ModeState.GameMode.DESTINATION, "Tried to board passenger, but not at a destination!")
	var slot: int = next_available_passenger_slot()
	if slot != -1:
		GameState.people_locations[person_id] = ID.Location.DEFAULT
		passenger_slots[slot] = person_id
		ModeState.update_train_avatars(false)
		return true
	return false

func offboard_passenger(person_id: ID.Person, location_id: ID.Location):
	assert(ModeState.mode == ModeState.GameMode.DESTINATION, "Tried to offboard passenger, but not at a destination!")
	for index in passenger_car_count * max_passengers_per_car:
		if passenger_slots[index] == person_id:
			passenger_slots[index] = ID.Person.DEFAULT
			GameState.people_locations[person_id] = location_id
			ModeState.update_train_avatars(false)
			return
	assert(false, "Offboarded passenger that wasn't on train!")

## Returns -1 if no slots available
func next_available_passenger_slot() -> int:
	for index in passenger_car_count * max_passengers_per_car:
		if passenger_slots[index] == ID.Person.DEFAULT:
			return index
	return -1

## Returns -1 if no slots available
func next_available_cargo_slot() -> int:
	for index in cargo_car_count:
		if cargo_slots[index] == ID.Cargo.DEFAULT:
			return index
	return -1

func person_on_train(id: ID.Person) -> bool:
	if id == ID.Person.DEFAULT: return false
	for index in passenger_car_count * max_passengers_per_car:
		if passenger_slots[index] == id:
			return true
	return false

func debug_text() -> String:
	var text: String = "Current location: " + ID.Location.keys()[current_location]
	text += "\nNext location: " + ID.Location.keys()[next_location]
	text += "\nCurrent Road: " + ID.Road.keys()[current_road]
	return text
