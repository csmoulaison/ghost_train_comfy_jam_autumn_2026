extends Node

var locations_unlocked: Array[bool]
var roads_unlocked: Array[bool]
var road_nodes: Array[MapRoad]
var location_nodes: Array[MapLocation]
var buying_tracks: bool = false
var cinematic: bool = false
var target_opacity: float = 0.0
var confirmation_road: ID.Road = ID.Road.DEFAULT
var coin_amount_initial_color: Color = Color("031727ff")

@onready var map_scene: Node = get_tree().current_scene.find_child("MapScene")
@onready var confirmation_dialog: Node = map_scene.get_node("ConfirmPopup")
@onready var confirmation_main_label: Label = confirmation_dialog.get_node("VBoxContainer/MainText")
@onready var confirmation_sub_label: Label = confirmation_dialog.get_node("VBoxContainer/Cost")
@onready var confirm_button: TextureButton = confirmation_dialog.get_node("VBoxContainer/Buttons/Confirm")
@onready var cancel_button: TextureButton = confirmation_dialog.get_node("VBoxContainer/Buttons/Cancel")
@onready var confirm_button_label: Label = confirm_button.get_node("Label")
@onready var cancel_button_label: Label = cancel_button.get_node("Label")
@onready var buy_boxcar_button: TextureButton = map_scene.get_node("BoxcarCard/VBoxContainer/BuyButton")
@onready var buy_coachcar_button: TextureButton = map_scene.get_node("CoachCard/VBoxContainer/BuyButton")
@onready var boxcar_pips: TextureRect = map_scene.get_node("BoxcarCard/VBoxContainer/LevelPips")
@onready var coachcar_pips: TextureRect = map_scene.get_node("CoachCard/VBoxContainer/LevelPips")
@onready var header_label: Label = map_scene.get_node("Header/Headline")
@onready var close_button_buy: TextureButton = map_scene.get_node("CloseButton1")
@onready var close_button_travel: TextureButton = map_scene.get_node("CloseButton2")
@onready var coin_amount: Label = map_scene.get_node("CoinCounter/PanelContainer/HBoxContainer/CoinAmount")
@onready var grotto_sparkles: AnimatedSprite2D = map_scene.get_node("GrottoSparkles")
@onready var cargo_only_ui_nodes: Array[Node] = []

func _ready():
	# Map scene stuff
	assert(map_scene != null)
	assert(confirmation_dialog != null)
	assert(confirm_button != null)
	assert(cancel_button != null)
	assert(buy_boxcar_button != null)
	assert(buy_coachcar_button != null)
	assert(header_label != null)
	assert(close_button_buy != null)
	assert(close_button_travel != null)
	assert(grotto_sparkles != null)
	cargo_only_ui_nodes.push_back(map_scene.get_node("Header/NameTag"))
	cargo_only_ui_nodes.push_back(map_scene.get_node("CoinCounter"))
	cargo_only_ui_nodes.push_back(map_scene.get_node("BoxcarCard"))
	cargo_only_ui_nodes.push_back(map_scene.get_node("CoachCard"))
	for node in cargo_only_ui_nodes: assert(node != null)
	
	coin_amount.modulate = coin_amount_initial_color
	map_scene.modulate.a = 0.0
	target_opacity = 0.0
	close_button_buy.pressed.connect(on_close_button)
	close_button_travel.pressed.connect(on_close_button)
	confirm_button.pressed.connect(_on_confirm_button)
	cancel_button.pressed.connect(_on_cancel_button)
	buy_boxcar_button.pressed.connect(_on_buy_boxcar_button)
	buy_coachcar_button.pressed.connect(_on_buy_coachcar_button)
	Cursor.define_hover(close_button_buy, Cursor.Type.POINT)
	Cursor.define_hover(close_button_travel, Cursor.Type.POINT)
	Cursor.define_hover(confirm_button, Cursor.Type.POINT)
	Cursor.define_hover(cancel_button, Cursor.Type.POINT)
	Cursor.define_hover(buy_boxcar_button, Cursor.Type.POINT)
	Cursor.define_hover(buy_coachcar_button, Cursor.Type.POINT)
	close_confirmation_dialog()
		
	locations_unlocked.resize(ID.Location.LOCATION_COUNT)
	locations_unlocked.fill(false)
	roads_unlocked.resize(ID.Road.ROAD_COUNT)
	roads_unlocked.fill(false)
	
	# TODO: debug unlock all
	if false:
		for road in ID.Road.ROAD_COUNT:
			unlock_road(road, false)
	else:
		unlock_road(ID.Road.FARMERS_MARKET_TO_PUMPKIN_PATCH, false)
		unlock_road(ID.Road.FARMERS_MARKET_TO_WITCHS_TRAIN_YARD, false)
	
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
	
	EventBus.event_signal.connect(on_event)

func _process(dt):
	map_scene.modulate.a = lerp(map_scene.modulate.a, target_opacity, dt * 16.0)
	if map_scene.modulate.a < 0.01: 
		map_scene.modulate.a = 0.0
		map_scene.visible = false
	else: map_scene.visible = true
	coin_amount.text = str(MoneyState.coins)
	coin_amount.modulate.r = lerp(coin_amount.modulate.r, coin_amount_initial_color.r, dt * 2.0)

func flash_coins():
	coin_amount.modulate.r = 1.0

func on_event(event: ID.Event, _arg: int):
	if event == ID.Event.OPEN_MAP_BUYING_GROTTO_TRACK:
		# TODO(now): cinematic for this
		unlock_road(ID.Road.SCHOOLYARD_TO_GRIMMS_GROTTO, false)

func _on_confirm_button():
	if buying_tracks:
		var road: Road = ResourceData.roads[confirmation_road]
		if MoneyState.try_coins(road.cost):
			AudioState.play(AudioState.train_sound_player_2.road_buy, AudioState.train_sound_player_2)
			MapState.unlock_road(confirmation_road, true)
		else:
			# NOTE: we should never hit this point, as we check player money
			# when they click on node and never bring up this menu
			assert(false)
		MapState.update_visual_state()
	else:
		close()
		ModeState.depart_to_travel()

func _on_cancel_button():
	if buying_tracks:
		confirmation_road = ID.Road.DEFAULT
	else: 
		TrainState.next_location = ID.Location.DEFAULT
		TrainState.current_road = ID.Road.DEFAULT
	MapState.update_visual_state()

func on_close_button():
	close()
	Cursor.change(Cursor.Type.NORMAL)
	ModeState.switch_mode(ModeState.GameMode.DESTINATION)
	if MapState.buying_tracks:
		DialogueState.open_dialogue([], close_button_buy.post_track_dialogue)
	if MapState.cinematic:
		DialogueState.open_dialogue([], close_button_buy.post_grotto_dialogue)

func _on_buy_boxcar_button():
	if MoneyState.try_coins(20):
		TrainState.cargo_car_count += 1
		boxcar_pips.texture = boxcar_pips.textures[TrainState.cargo_car_count - 1]
		AudioState.play(boxcar_pips.upgrade_sound, AudioState.train_sound_player_2)
		ModeState.place_train_cars()
		if TrainState.cargo_car_count > 3: buy_boxcar_button.disabled = true
	else:
		flash_coins()

func _on_buy_coachcar_button():
	if MoneyState.try_coins(20):
		TrainState.passenger_car_count += 1
		coachcar_pips.texture = coachcar_pips.textures[TrainState.passenger_car_count - 1]
		AudioState.play(coachcar_pips.upgrade_sound, AudioState.train_sound_player_2)
		ModeState.place_train_cars()
		if TrainState.passenger_car_count > 2: buy_coachcar_button.disabled = true
	else:
		flash_coins()

func unlock_road(road_id: ID.Road, visual_update: bool):
	var road: Road = ResourceData.roads[road_id]
	roads_unlocked[road_id] = true
	locations_unlocked[road.endpoint_1] = true
	locations_unlocked[road.endpoint_2] = true
	if visual_update: update_visual_state()

func open_confirmation_dialog(main_text: String, sub_text: String, yes_text: String, no_text: String):
	if cinematic: return
	confirmation_main_label.text = main_text
	confirmation_sub_label.text = sub_text
	confirm_button_label.text = yes_text
	cancel_button_label.text = no_text
	confirmation_dialog.visible = true
	pass

func close_confirmation_dialog():
	confirmation_dialog.visible = false
	pass

func open():
	target_opacity = 1.0
	if buying_tracks: 
		for node in cargo_only_ui_nodes: node.modulate.a = 1.0
		close_button_buy.visible = true
		close_button_travel.visible = false
		header_label.text = "What'll it be?"
	else:
		for node in cargo_only_ui_nodes: node.modulate.a = 0.0
		close_button_buy.visible = false
		close_button_travel.visible = true
		header_label.text = "Choose a destination."
	if cinematic: 
		header_label.text = "Let's see here..."
		grotto_sparkles.visible = true
	else: grotto_sparkles.visible = false
	update_visual_state()

func close():
	target_opacity = 0.0

func update_visual_state():
	for id in ID.Location.LOCATION_COUNT:
		if id == 0: continue
		var node: MapLocation = location_nodes[id]
		assert(node != null)
		node.set_visual_active_state(node.location_id == TrainState.current_location)
		node.set_markers(node.location_id == TrainState.current_location, false)
	for id in ID.Road.ROAD_COUNT:
		if id == 0: continue
		var node: MapRoad = road_nodes[id]
		assert(node != null)
		var buyable: bool = false
		var road: Road = ResourceData.roads[id]
		if !MapState.roads_unlocked[id] and (MapState.locations_unlocked[road.endpoint_1] or MapState.locations_unlocked[road.endpoint_2]):
			buyable = true
		if !MapState.buying_tracks: buyable = false
		node.set_visual_active_state(false, buyable, road.buy_texture)
	close_confirmation_dialog()
