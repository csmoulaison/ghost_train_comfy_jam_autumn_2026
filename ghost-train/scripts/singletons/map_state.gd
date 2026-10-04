extends Node

var road_nodes: Array[Node]
@onready var map_scene: Node = get_tree().current_scene.find_child("MapScene")

func _ready() -> void:
	assert(map_scene != null)
	road_nodes.resize(ID.Road.ROAD_COUNT)
	# NOTE: all the roads names need to start with "MapRoad"
	for node in map_scene.find_children("MapRoad*"):
		for road_id in ID.Road.ROAD_COUNT:
			if node.road_id == road_id:
				road_nodes[road_id] = node
	
	for node in road_nodes:
		# TODO: This assert should be turned on once we can. It verifies that 
		# every Road ID has a corresponding road object in the map scene.
		# assert(node != null)
		pass
