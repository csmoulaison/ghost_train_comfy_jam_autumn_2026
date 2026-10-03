extends Node

var people: Array[Person] = []
var locations: Array[Location] = []

func _init() -> void:
	# Load person resources
	people.resize(Types.Person.PERSON_COUNT)
	for id in Types.Person.PERSON_COUNT:
		var enum_as_string = Types.Person.keys()[id].to_lower()
		var resource_path = "res://resources/people/%s.tres" % enum_as_string
		var resource = load(resource_path)
		assert(resource != null, "Ask Conner if confused: Failed to load person resource! All Types.Person values (found in scripts/types.gd) must have a matching Person resource of the same name, but lowercase, in resources/people/name_in_lowercase.tres")
		people[id] = load(resource_path)
		
	# Load location resources	
	locations.resize(Types.Location.LOCATION_COUNT)
	for id in Types.Location.LOCATION_COUNT:
		var enum_as_string = Types.Location.keys()[id].to_lower()
		var resource_path = "res://resources/locations/%s.tres" % enum_as_string
		var resource = load(resource_path)
		assert(resource != null, "Ask Conner if confused: Failed to load location resource! All Types.Location values (found in scripts/types.gd) must have a matching Location resource of the same name, but lowercase, in resources/locations/name_in_lowercase.tres")
		locations[id] = load(resource_path)
