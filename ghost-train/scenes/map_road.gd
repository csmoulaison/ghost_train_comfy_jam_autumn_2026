class_name MapRoad extends Node2D

@export var road_id: ID.Road
@export var locked_texture: Texture2D
@export var inactive_texture: Texture2D
@export var active_texture: Texture2D

@onready var sprite_node: Sprite2D = get_node("Sprite2D")

func ready():
	assert(sprite_node != null)

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if !MapState.buying_tracks: return
		if MapState.roads_unlocked[road_id]: return
		
		# TODO: confirmation dialog box for road purchases
		var road: Road = ResourceData.roads[road_id]
		if MoneyState.try_coins(road.cost):
			MapState.unlock_road(road_id, true)
		else:
			# TODO: feedback for not having enough monies
			print("player didn't have enough coins to purchase track.")

# NOTE: this is virtually identical to set_visual_active_state in MapLocation
func set_visual_active_state(active: bool):
	if !MapState.roads_unlocked[road_id]:
		sprite_node.texture = locked_texture
		return
	if active:
		sprite_node.texture = active_texture
	else:
		sprite_node.texture = inactive_texture
