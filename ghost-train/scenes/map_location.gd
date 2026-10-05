class_name MapLocation extends Node2D

@export var location_id: ID.Location
@export var locked_texture: Texture2D
@export var inactive_texture: Texture2D
@export var active_texture: Texture2D

@onready var sprite_node: Sprite2D = get_node("Sprite2D")

func _ready():
	assert(sprite_node != null)
	assert(location_id != ID.Location.DEFAULT and location_id != ID.Location.LOCATION_COUNT, "Location_id unset in map node " + self.to_string())

func _input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("clicked location")
		var valid_path: bool = false
		if MapState.locations_unlocked[location_id]:
			for road_id in ID.Road.ROAD_COUNT:
				var road: Road = ResourceData.roads[road_id]
				# TODO: pathfinding? or just single road travels?
				if road.endpoint_1 == TrainState.current_location and road.endpoint_2 == location_id:
					select_node(road.endpoint_2, road_id)
					valid_path = true
					break
				if road.endpoint_2 == TrainState.current_location and road.endpoint_1 == location_id:
					select_node(road.endpoint_1, road_id)
					valid_path = true
					break
					
		if !valid_path:
			# TODO: feedback to player that the selection was invalid
			print("Invalid map path selected by player.")

func select_node(location: ID.Location, road: ID.Road):
	MapState.road_nodes[road].set_visual_active_state(true)
	MapState.location_nodes[location].set_visual_active_state(true)
	TrainState.next_location = location
	TrainState.current_road = road
	MapState.open_confirmation_dialog()

# NOTE: this is virtually identical to set_visual_active_state in MapNode
func set_visual_active_state(active: bool):
	if !MapState.locations_unlocked[location_id]:
		sprite_node.texture = locked_texture
		return
	if active:
		sprite_node.texture = active_texture
	else:
		sprite_node.texture = inactive_texture
