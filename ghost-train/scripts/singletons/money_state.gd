extends Node

var coins: int = 0

# TODO(now): we want to purchase witch stuff with this

func try_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		return true
	return false

func add_coins(amount: int):
	print("adding from money state")
	coins += amount

func remove_coins(amount: int):
	coins -= amount
	if MoneyState.coins < 0:
		push_error("Didn't check if the player had enough coins before remove_coins call!")
		MoneyState.coins = 0

func debug_text() -> String:
	var text: String = "Coins: " + str(coins)
	return text
