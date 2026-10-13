extends Node

var flags: Array[bool]
var people_locations: Array[ID.Location]
var people_on_train: Array[bool]
var cargo_cooldowns: Array[int]

func _ready():
	# Initialize state arrays
	flags.resize(ID.Flag.FLAG_COUNT)
	flags.fill(false)
	
	people_on_train.resize(ID.Person.PERSON_COUNT)
	people_on_train.fill(false)
	
	cargo_cooldowns.resize(ID.Cargo.CARGO_COUNT)
	cargo_cooldowns.fill(0)
	
	# Put people in their starting location as defined by their Person resource
	people_locations.resize(ID.Person.PERSON_COUNT)
	for id in ID.Person.PERSON_COUNT:
		var person: Person = ResourceData.people[id]
		people_locations[id] = person.starting_location
		if people_locations[id] != ID.Person.DEFAULT:
			pass
		# TODO: once we have them set up, maybe this assert makes sense?
		# assert(person.starting_location != ID.Person.DEFAULT)
	
	EventBus.event_signal.connect(_on_event)

func _on_event(event: ID.Event, _arg: int):
	if event != ID.Event.SCATTER_JACKOKIDS: return
	people_locations[ID.Person.JACKOKID_1] = ID.Location.FARMERS_MARKET
	people_locations[ID.Person.JACKOKID_2] = ID.Location.WITCHS_TRAIN_YARD
	people_locations[ID.Person.JACKOKID_3] = ID.Location.CORN_TOWN
	people_locations[ID.Person.JACKOKID_4] = ID.Location.LAKE_OF_OAKS
	people_locations[ID.Person.JACKOKID_5] = ID.Location.SCHOOLYARD
	people_locations[ID.Person.JACKOKID_6] = ID.Location.FUNGI_FOREST
	people_locations[ID.Person.JACKOKID_7] = ID.Location.GRIMMS_GROTTO
	people_locations[ID.Person.JACKOKID_8] = ID.Location.GRAVEYARD

func debug_text() -> String:
	return "Vampire Talked To: " + str(flags[ID.Flag.TALKED_TO_VAMPIRE])	
