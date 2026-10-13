class_name StateEffect extends Resource

@export var fire_event: ID.Event
@export var set_flag: ID.Flag
@export var board_person: ID.Person
@export var offboard_person: ID.Person
@export var load_cargo: ID.Cargo
@export var sell_cargo: ID.Cargo
@export var load_small_cargo: ID.SmallCargo
@export var unload_small_cargo: ID.SmallCargo
@export var revenue: int
@export var cost: int

# TODO: sound effect?
func fire():
	if board_person != ID.Person.DEFAULT:
		TrainState.try_board_passenger(board_person)
	if offboard_person != ID.Person.DEFAULT:
		TrainState.offboard_passenger(offboard_person, TrainState.current_location)
	if load_cargo != ID.Cargo.DEFAULT:
		TrainState.try_load_cargo(load_cargo)
	if sell_cargo != ID.Cargo.DEFAULT:
		TrainState.sell_cargo(sell_cargo)
	if load_small_cargo != ID.SmallCargo.DEFAULT:
		TrainState.small_cargo_on_train[load_small_cargo] = true
	if unload_small_cargo != ID.SmallCargo.DEFAULT:
		TrainState.small_cargo_on_train[unload_small_cargo] = false
	if revenue > 0:
		MoneyState.add_coins(revenue)
	if cost > 0:
		MoneyState.remove_coins(revenue)
	if fire_event != ID.Event.DEFAULT:
		EventBus.event_signal.emit(fire_event, 0)
	if set_flag != ID.Flag.DEFAULT:
		GameState.flags[set_flag] = true
	return false

static func fire_list(effects: Array[StateEffect]):
	for effect in effects:
		effect.fire()
