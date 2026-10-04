extends Node2D

#TODO: runtime check to make sure all locations are set
@export var location_id: ID.Location

func _ready() -> void:
	assert(location_id != ID.Location.DEFAULT and location_id != ID.Location.LOCATION_COUNT, "Location_id unset in map node " + self.to_string())

func _input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# TODO: confirmation dialog appears first
		for road_id in ID.Road.ROAD_COUNT:
			var road: Road = ResourceData.roads[road_id]
			# TODO: pathfinding? or just single road travels?
			if road.endpoint_1 == TrainState.current_or_next_location and road.endpoint_2 == location_id:
				# same logic as below, but reversed locations
				ModeState.enter_travel_mode(road_id)
				TrainState.current_or_next_location = road.endpoint_2
				return
			if road.endpoint_2 == TrainState.current_or_next_location and road.endpoint_1 == location_id:
				# same logic as above, but reversed locations
				ModeState.enter_travel_mode(road_id)
				TrainState.current_or_next_location = road.endpoint_1
				return
		# TODO: feedback to player that the selection was invalid
		print("Invalid map path selected by player.")
