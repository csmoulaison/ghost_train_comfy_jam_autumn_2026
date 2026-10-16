class_name MapRoad extends Node2D

@export var road_id: ID.Road
@export var locked_texture: Texture2D
@export var inactive_texture: Texture2D
@export var active_texture: Texture2D

@export var try_grotto_dialogue: DialogueLine
@export var post_grotto_unlock_dialogue: DialogueLine

@onready var sprite_node: Sprite2D = get_node("Sprite2D")
@onready var buy_indicator_node: Sprite2D = get_node("BuyIndicator")

var buyable: bool = false

func _ready():
	assert(sprite_node != null)
	assert(buy_indicator_node != null)

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int):	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#if ModeState.control_paused(): return
		if !MapState.buying_tracks: return
		if MapState.roads_unlocked[road_id]: return
		
		var road: Road = ResourceData.roads[road_id]
		
		# TODO: feedback for not having adjacent roads
		if !MapState.locations_unlocked[road.endpoint_1] and !MapState.locations_unlocked[road.endpoint_2]:
			return
			
		if !GameState.flags[ID.Flag.GROTTO_ROAD_AVAILABLE] and road_id == ID.Road.SCHOOLYARD_TO_GRIMMS_GROTTO: 
			DialogueState.open_dialogue([], try_grotto_dialogue)
			return
			
		# TODO: feedback for not having enough monies. we are flashing red + we want a sound
		if road.cost > MoneyState.coins: 
			MapState.flash_coins()
			return
		
		var end1: Location = ResourceData.locations[road.endpoint_1]
		var end2: Location = ResourceData.locations[road.endpoint_2]
		MapState.confirmation_road = road_id
		MapState.open_confirmation_dialog(end1.name + " - " + end2.name, str(road.cost) + " Coins", "Buy Track", "Cancel")

func set_visual_active_state(active: bool, buy: bool, buy_texture: Texture2D):
	buyable = buy
	if buyable: 
		buy_indicator_node.modulate.a = 1.0
	else: 
		buy_indicator_node.modulate.a = 0.0
	buy_indicator_node.texture = buy_texture
	
	if !MapState.roads_unlocked[road_id]:
		sprite_node.texture = locked_texture
		return
	if active:
		sprite_node.texture = active_texture
	else:
		sprite_node.texture = inactive_texture
