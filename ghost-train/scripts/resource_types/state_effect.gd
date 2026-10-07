class_name StateEffect extends Resource

@export var events: Array[ID.Event] = []
@export var boards: Array[BoardEffect] = []
@export var offboards: Array[OffboardEffect] = []
@export var payments: Array[PaymentEffect] = []

func fire():
	for board in boards:
		TrainState.try_board_passenger(board.person)
	for offboard in offboards:
		TrainState.offboard_passenger(offboard.person, TrainState.current_location)
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
