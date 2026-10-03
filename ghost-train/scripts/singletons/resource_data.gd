extends Node

var people: Array[Person] = []
var locations: Array[Location] = []
var dialogue_chains: Array[DialogueChain] = []

func _init() -> void:
	initialize_resource_type(people, ID.Person, "people")
	initialize_resource_type(locations, ID.Location, "locations")

func initialize_resource_type(list: Array, enum_dictionary: Dictionary, resource_folder_name: String) -> void:
	var count = enum_dictionary.size() - 1
	list.resize(count)
	for id in count:
		var enum_as_string = enum_dictionary.keys()[id].to_lower()
		var resource_path = "res://resources/" + resource_folder_name + "/%s.tres" % enum_as_string
		var resource = load(resource_path)
		assert(resource != null, "Ask Conner if confused: Failed to load " + resource_folder_name + " resource at '" + resource_path + "'. All resource IDs of this type (found in scripts/id.gd) must have a matching resource in the corresponding resources folder.")
		list[id] = load(resource_path)
