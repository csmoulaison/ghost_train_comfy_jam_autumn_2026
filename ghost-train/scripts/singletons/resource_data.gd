extends Node

var people: Array[Person] = []
var locations: Array[Location] = []
var roads: Array[Road] = []
var cargos: Array[Cargo] = []
var small_cargos: Array[SmallCargo] = []

func _init():
	ResourceLoad.initialize_resource_type(people, ID.Person, "people")
	ResourceLoad.initialize_resource_type(locations, ID.Location, "locations")
	ResourceLoad.initialize_resource_type(roads, ID.Road, "roads")
	ResourceLoad.initialize_resource_type(cargos, ID.Cargo, "cargos")
	ResourceLoad.initialize_resource_type(small_cargos, ID.SmallCargo, "small_cargos")
