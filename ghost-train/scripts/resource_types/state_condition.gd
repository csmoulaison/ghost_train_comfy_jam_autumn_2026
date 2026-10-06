class_name StateCondition extends Resource

@export var flags: Array[FlagCondition] = []
@export var person_locations: Array[PersonLocationCondition] = []
@export var cargo: Array[CargoCondition] = []
@export var small_cargo: Array[SmallCargoCondition] = []
@export var money_conditions: Array[MoneyCondition] = []

func check() -> bool:
	for flag in flags:
		if flag.must_be_false: 
			if GameState.flags[flag.id]: return false
		else: if !GameState.flags[flag.id]: return false
	for pl in person_locations:
		if pl.must_not_be_in_location: 
			if GameState.people_locations[pl.person] == pl.location: 
				return false
		else: if GameState.people_locations[pl.person] != pl.location: 
			return false
	# TODO(now): check cargo and small cargo conditions.
	for mc in money_conditions:
		if mc.must_be_below: 
			if MoneyState.coins >= mc.amount: return false
		else: if MoneyState.coins < mc.amount: return false
	return true

static func check_list(conditions: Array[StateCondition]) -> bool:
	for condition in conditions:
		if !condition.check(): return false
	return true
