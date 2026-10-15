class_name MapLocation extends Node2D

@export var location_id: ID.Location
@export var locked_texture: Texture2D
@export var inactive_texture: Texture2D
@export var active_texture: Texture2D

@onready var sprite_node: Sprite2D = get_node("Sprite2D")

func _ready():
	assert(sprite_node != null)
	assert(location_id != ID.Location.DEFAULT and location_id != ID.Location.LOCATION_COUNT, "Location_id unset in map node " + self.to_string())

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if MapState.buying_tracks: return
		
		var valid_path: bool = false
		if MapState.locations_unlocked[location_id] and location_id != TrainState.current_location:
			select_node(location_id, ID.Road.FARMERS_MARKET_TO_PUMPKIN_PATCH, true)
			#for road_id in ID.Road.ROAD_COUNT:
				#var road: Road = ResourceData.roads[road_id]
				#if road.endpoint_1 == TrainState.current_location and road.endpoint_2 == location_id:
					#select_node(road.endpoint_2, road_id, true)
					#valid_path = true
					#break
				#if road.endpoint_2 == TrainState.current_location and road.endpoint_1 == location_id:
					#select_node(road.endpoint_1, road_id, true)
					#valid_path = true
					#break

		if !valid_path:
			# TODO: feedback to player that the selection was invalid
			print("Invalid map path selected by player.")

static func select_node(new_location_id: ID.Location, road_id: ID.Road, confirmation: bool):
	#MapState.road_nodes[road_id].set_visual_active_state(true)
	for index in ID.Location.LOCATION_COUNT:
		if index == 0: continue
		MapState.location_nodes[index].set_visual_active_state(false)
	MapState.location_nodes[TrainState.current_location].set_visual_active_state(true)
	MapState.location_nodes[new_location_id].set_visual_active_state(true)
	TrainState.next_location = new_location_id
	TrainState.current_road = road_id
	var location: Location = ResourceData.locations[new_location_id]
	if confirmation:
		MapState.open_confirmation_dialog("Do you want to go\nto " + location.name + "?")

# NOTE: this is virtually identical to set_visual_active_state in MapNode
func set_visual_active_state(active: bool):
	if !MapState.locations_unlocked[location_id]:
		sprite_node.texture = locked_texture
		return
	if active:
		sprite_node.texture = active_texture
	else:
		sprite_node.texture = inactive_texture
