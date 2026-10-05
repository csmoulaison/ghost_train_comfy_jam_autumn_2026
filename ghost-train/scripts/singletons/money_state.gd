extends Node

var coins: int = 0

# TODO(now): we want to purchase witch stuff with this

func try_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		return true
	return false

func debug_text() -> String:
	var text: String = "Coins: " + str(coins)
	return text
