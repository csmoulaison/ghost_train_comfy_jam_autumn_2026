class_name StateEffect extends Resource

@export var events: Array[ID.Event] = []
@export var boards: Array[BoardEffect] = []
@export var offboards: Array[OffboardEffect] = []
@export var cargo_sells: Array[CargoSellEffect] = []
@export var cargo_loads: Array[CargoLoadEffect] = []
@export var payments: Array[PaymentEffect] = []

func fire():
	for board in boards:
		assert(TrainState.try_board_passenger(board.person), "Boarded passenger without checking room first!")
	for offboard in offboards:
		TrainState.offboard_passenger(offboard.person, TrainState.current_location)
	for sell in cargo_sells:
		TrainState.sell_cargo(sell.cargo)
	for cload in cargo_loads:
		assert(TrainState.try_load_cargo(cload.cargo), "Loaded cargo without checking room first!")
	for payment in payments:
		if payment.losing_money: 
			MoneyState.remove_coins(payment.amount)
		else: 
			print("adding coins from effect")
			MoneyState.add_coins(payment.amount)
	for event in events:
		EventBus.event_signal.emit(event, 0)
	return false

static func fire_list(effects: Array[StateEffect]):
	for effect in effects:
		effect.fire()
