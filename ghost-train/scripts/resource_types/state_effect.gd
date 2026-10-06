class_name StateEffect extends Resource

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
			MoneyState.coins -= payment.amount
			if MoneyState.coins < 0:
				push_error("Didn't if the player had enough coins before losing_money payment effect!")
				MoneyState.coins = 0
		else: MoneyState.coins += payment.amount
	return false

static func fire_list(effects: Array[StateEffect]):
	for effect in effects:
		effect.fire()
