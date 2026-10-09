extends Node

# TODO: button for leaving map screen without entering travel mode, or when
# buying tracks.

var locations_unlocked: Array[bool]
var roads_unlocked: Array[bool]
var road_nodes: Array[MapRoad]
var location_nodes: Array[MapLocation]
var buying_tracks: bool = false

@onready var map_scene: Node = get_tree().current_scene.find_child("MapScene")
@onready var confirmation_dialog: Node = map_scene.get_node("TravelConfirmationDialog")

func _ready():
	assert(map_scene != null)
	assert(confirmation_dialog != null)
	close_confirmation_dialog()
	
	locations_unlocked.resize(ID.Location.LOCATION_COUNT)
	locations_unlocked.fill(false)
	roads_unlocked.resize(ID.Road.ROAD_COUNT)
	roads_unlocked.fill(false)
	
	# TODO: debug unlock all
	if true:
		for road in ID.Road.ROAD_COUNT:
			unlock_road(road, false)
	else:
		unlock_road(ID.Road.FARMERS_MARKET_TO_PUMPKIN_PATCH, false)
	
	road_nodes.resize(ID.Road.ROAD_COUNT)
	# NOTE: all the roads names need to start with "MapRoad"
	for node in map_scene.find_children("MapRoad*"):
		for id in ID.Road.ROAD_COUNT:
			if node.road_id == id:
				road_nodes[id] = node
	# NOTE: all the roads names need to start with "MapLocation"
	location_nodes.resize(ID.Location.LOCATION_COUNT)
	for node in map_scene.find_children("MapLocation*"):
		for id in ID.Location.LOCATION_COUNT:
			if node.location_id == id:
				location_nodes[id] = node
	
	# TODO: These asserts should be turned on once we can. They verify that
	# every Road/Location ID has a corresponding road/location node in the map
	# scene.
	for node in road_nodes:
		# assert(node != null)
		pass
	for node in location_nodes:
		# assert(node != null)
		pass

func unlock_road(road_id: ID.Road, visual_update: bool):
	var road: Road = ResourceData.roads[road_id]
	roads_unlocked[road_id] = true
	locations_unlocked[road.endpoint_1] = true
	locations_unlocked[road.endpoint_2] = true
	if visual_update: init_visual_state()

func open_confirmation_dialog():
	map_scene.add_child(confirmation_dialog)
	pass

func close_confirmation_dialog():
	map_scene.remove_child(confirmation_dialog)
	pass

func init_visual_state():
	for id in ID.Location.LOCATION_COUNT:
		var node: MapLocation = location_nodes[id]
		if node != null:
			node.set_visual_active_state(node.location_id == TrainState.current_location)
	for id in ID.Road.ROAD_COUNT:
		var node: MapRoad = road_nodes[id]
		if node != null:
			node.set_visual_active_state(false)
	close_confirmation_dialog()
