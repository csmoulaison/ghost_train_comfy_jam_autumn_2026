extends Node

var flags: Array[bool]
var people_locations: Array[ID.Location]
var people_on_train: Array[bool]

func _ready():
	# Initialize state arrays
	flags.resize(ID.Flag.FLAG_COUNT)
	flags.fill(false)
	
	people_on_train.resize(ID.Person.PERSON_COUNT)
	people_on_train.fill(false)
	
	# Put people in their starting location as defined by their Person resource
	people_locations.resize(ID.Person.PERSON_COUNT)
	for id in ID.Person.PERSON_COUNT:
		var person: Person = ResourceData.people[id]
		people_locations[id] = person.starting_location
		# TODO: once we have them set up, maybe this assert makes sense?
		# assert(person.starting_location != ID.Person.DEFAULT)
