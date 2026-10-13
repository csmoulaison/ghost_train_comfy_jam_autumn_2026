class_name StateCondition extends Resource

@export var flag_true: ID.Flag = ID.Flag.DEFAULT
@export var flag_false: ID.Flag = ID.Flag.DEFAULT
@export var person_at_location: PersonLocationPair
@export var person_not_at_location: PersonLocationPair
@export var person_on_train: ID.Person = ID.Person.DEFAULT
@export var person_not_on_train: ID.Person = ID.Person.DEFAULT
@export var cargo_loaded: ID.Cargo = ID.Cargo.DEFAULT
@export var cargo_not_loaded: ID.Cargo = ID.Cargo.DEFAULT
@export var small_cargo_loaded: ID.SmallCargo = ID.SmallCargo.DEFAULT
@export var small_cargo_not_loaded: ID.SmallCargo = ID.SmallCargo.DEFAULT
@export var money_state: MoneyCondition
@export var road_unlocked: ID.Road = ID.Road.DEFAULT
@export var road_locked: ID.Road = ID.Road.DEFAULT
@export var location_unlocked: ID.Location = ID.Location.DEFAULT
@export var location_locked: ID.Location = ID.Location.DEFAULT
@export var passenger_slot_available: bool = false
@export var cargo_slot_available: bool = false
@export var cargo_available: ID.Cargo = ID.Cargo.DEFAULT
@export var cargo_not_available: ID.Cargo = ID.Cargo.DEFAULT

func check() -> bool:
	if flag_true != ID.Flag.DEFAULT and !GameState.flags[flag_true]: return false
	if flag_false != ID.Flag.DEFAULT and GameState.flags[flag_false]: return false
	if person_at_location != null and person_at_location.person != ID.Person.DEFAULT and person_at_location.location != ID.Location.DEFAULT:
		if GameState.people_locations[person_at_location.person] != person_at_location.location: return false
	if person_not_at_location != null and person_not_at_location.person != ID.Person.DEFAULT and person_not_at_location.location != ID.Location.DEFAULT:
		if GameState.people_locations[person_not_at_location.person] == person_not_at_location.location: return false
	if person_on_train != ID.Person.DEFAULT and !TrainState.person_on_train(person_on_train): return false
	if person_not_on_train != ID.Person.DEFAULT and TrainState.person_on_train(person_on_train): return false
	if cargo_loaded != ID.Cargo.DEFAULT and !TrainState.cargo_on_train(cargo_loaded): return false
	if cargo_not_loaded != ID.Cargo.DEFAULT and TrainState.cargo_on_train(cargo_not_loaded): return false
	if small_cargo_loaded != ID.SmallCargo.DEFAULT and !TrainState.small_cargo_on_train[small_cargo_loaded]: return false
	if small_cargo_not_loaded != ID.SmallCargo.DEFAULT and TrainState.small_cargo_on_train[small_cargo_not_loaded]: return false
	if money_state != null and money_state.amount != 0: assert(false) # TODO: check
	if road_unlocked != ID.Road.DEFAULT and !MapState.roads_unlocked[road_unlocked]: return false
	if road_locked != ID.Road.DEFAULT and MapState.roads_unlocked[road_locked]: return false
	if location_unlocked != ID.Location.DEFAULT and !MapState.locations_unlocked[location_unlocked]: return false
	if location_locked != ID.Location.DEFAULT and MapState.locations_unlocked[location_locked]: return false
	if passenger_slot_available and TrainState.next_available_passenger_slot() == -1: return false
	if cargo_slot_available and TrainState.next_available_cargo_slot() == -1: return false
	if cargo_available != ID.Cargo.DEFAULT and GameState.cargo_cooldowns[cargo_available] > 0: return false
	if cargo_not_available != ID.Cargo.DEFAULT and GameState.cargo_cooldowns[cargo_not_available] <= 0: return false
	return true

static func check_list(conditions: Array[StateCondition]) -> bool:
	for condition in conditions:
		if condition == null: continue
		if !condition.check(): return false
	return true
