extends Node

var flags: Array[bool]
var people_locations: Array[ID.Location]

func _ready() -> void:
	# Initialize all flags to false
	flags.resize(ID.Flag.FLAG_COUNT)
	for id in ID.Flag.FLAG_COUNT:
		flags[id] = false
	
	# Put people in their starting location as defined by their Person resource
	people_locations.resize(ID.Person.PERSON_COUNT)
	for id in ID.Person.PERSON_COUNT:
		var person: Person = ResourceData.people[id]
		people_locations[id] = person.starting_location
