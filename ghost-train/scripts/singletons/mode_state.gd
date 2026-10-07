extends Node

enum GameMode {
	ONLY_CINEMATIC,
	TRAVEL,
	DESTINATION,
	MAP,
	MAIN_MENU,
}

# WARNING: IF YOU ADD A SCENE NODE HERE, UPDATE remove_all_scenes() FUNCTION
@onready var scene_parent: Node = get_tree().current_scene
@onready var travel_scene: Node = scene_parent.find_child("TravelScene")
@onready var travel_subscene_parent: Node = travel_scene.find_child("SubsceneParent")
@onready var destination_scene: Node = scene_parent.find_child("DestinationScene")
@onready var destination_subscene_parent: Node = destination_scene.find_child("SubsceneParent")
@onready var map_scene: Node = scene_parent.find_child("MapScene")
@onready var main_menu_scene: Node = scene_parent.find_child("MainMenuScene")
@onready var pause_menu_scene: Node = scene_parent.find_child("PauseMenuScene")

var loaded_scene_instance: Node = null
var mode: GameMode = GameMode.DESTINATION
var initialized: bool = false
var pause_menu: bool = false

func _ready() :
	assert(travel_scene != null)
	assert(travel_subscene_parent != null)
	assert(destination_scene != null)
	assert(destination_subscene_parent != null)
	assert(map_scene != null)
	assert(main_menu_scene != null)
	assert(pause_menu_scene != null)
	EventBus.event_signal.connect(_on_event)

func _process(_dt: float):
	# NOTE: This is done so that every node's _ready function runs on game
	# startup. Calling enter_destination_mode in our _ready would precede that
	# happening in the case of all non autoload singletons, and in the case of
	# singletons, forces the brittle constraint of ModeState being at the bottom
	# of the Project Settings->Globals->Autoload list
	if !initialized:
		initialized = true
		# TODO: start at main menu, presumably
		TrainState.current_location = ID.Location.FARMERS_MARKET
		switch_mode(GameMode.MAIN_MENU)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if ModeState.pause_menu:
			scene_parent.remove_child(pause_menu_scene)
			pause_menu = false
		else: 
			add_scene(pause_menu_scene)
			pause_menu = true

func start_from_menu():
	CinematicState.start_cinematic(ID.Cinematic.INTRO_1, true)
	
func arrive_at_destination(location_id: ID.Location):
	switch_mode(GameMode.DESTINATION)
	TrainState.current_location = location_id
	TrainState.next_location = ID.Location.DEFAULT
	TrainState.current_road = ID.Road.DEFAULT
	load_destination_mode(location_id)
	for passenger_index in TrainState.passenger_car_count * TrainState.max_passengers_per_car:
		var passenger_id: ID.Person = TrainState.passenger_slots[passenger_index]
		if passenger_id == ID.Person.DEFAULT: 
			continue
		var passenger: Person = ResourceData.people[passenger_id]
		if passenger.desired_location == TrainState.current_location:
			DialogueState.open_dialogue([], passenger.reached_location_dialogue)

func load_destination_mode(location_id: ID.Location):
	if mode != GameMode.DESTINATION: 
		switch_mode(GameMode.DESTINATION)
	var location: Location = ResourceData.locations[location_id]
	load_subscene(destination_subscene_parent, location.subscene_path)	
	update_train_avatars()
	update_destination_avatars()
	
func depart_to_travel():
	switch_mode(GameMode.TRAVEL)
	TrainState.current_location = ID.Location.DEFAULT
	var road: Road = ResourceData.roads[TrainState.current_road]
	load_subscene(travel_subscene_parent, road.subscene_path)
	update_train_avatars()
	ParallaxState.begin_parallax()

func _on_event(event: ID.Event, _arg: int):
	if event == ID.Event.OPEN_MAP_BUYING_TRACKS:
		enter_map_mode(true)

func enter_map_mode(buying_tracks: bool):
	MapState.buying_tracks = buying_tracks
	switch_mode(GameMode.MAP)
	MapState.init_visual_state()

func switch_mode(new_mode: GameMode):
	if mode == GameMode.TRAVEL:
		ParallaxState.end_parallax()

	mode = new_mode
	remove_all_scenes()
	match mode:
		GameMode.TRAVEL:
			add_scene(travel_scene)
		GameMode.DESTINATION:
			add_scene(destination_scene)
		GameMode.MAP:
			add_scene(map_scene)
		GameMode.MAIN_MENU:
			add_scene(main_menu_scene)
		GameMode.ONLY_CINEMATIC:
			pass

## removes scenes from the root's children, but keeps their state in memory for
## retrieval later.
func remove_all_scenes():
	scene_parent.remove_child(travel_scene)
	scene_parent.remove_child(destination_scene)
	scene_parent.remove_child(map_scene)
	scene_parent.remove_child(main_menu_scene)
	scene_parent.remove_child(pause_menu_scene)

## adds a node to the root's children, restoring whatever state it had before it
## was removed (unless it was screwed with somehow in the interim)
func add_scene(scene_node: Node):
	scene_parent.add_child(scene_node)

## Dynamic state that we want to pause, for instance, during cinematics or while
## a pause screen is active, should check if this returns true.
func control_paused() -> bool:
	if mode == GameMode.ONLY_CINEMATIC: return true
	if CinematicState.current_cinematic != ID.Cinematic.DEFAULT: return true
	if pause_menu: return true
	if DialogueState.is_active(): return true
	return false

func load_subscene(parent: Node, subscene_path: String):
	if loaded_scene_instance != null:
		loaded_scene_instance.queue_free()
		loaded_scene_instance = null
	var scene: PackedScene = load(subscene_path)
	print(scene)
	assert(scene != null, "Ask Conner: Couldn't load subscene '" + subscene_path + "'. Has it been set?")
	loaded_scene_instance = scene.instantiate()
	print(loaded_scene_instance)
	assert(loaded_scene_instance != null)
	parent.add_child(loaded_scene_instance)

func update_destination_avatars():
	var avatars: Array[Node] = loaded_scene_instance.find_children("PersonAvatar*", "", false)
	for avatar in avatars:
		avatar.visible = false
		avatar.process_mode = Node.PROCESS_MODE_DISABLED

	for id in ID.Person.PERSON_COUNT:
		if GameState.people_locations[id] != TrainState.current_location:
			continue
		var avatar_found: bool = false
		for avatar in avatars:
			if avatar.person_id == id:
				avatar_found = true
				draw_person_avatar(avatar, id)
				break
		assert(avatar_found, "No matching avatar at destination.")
	
func update_train_avatars():
	var train_avatar: Node = null
	if mode == GameMode.DESTINATION:
		train_avatar = loaded_scene_instance.get_node("TrainAvatar")
	else: if mode == GameMode.TRAVEL:
		train_avatar = travel_scene.get_node("TrainAvatar")
	assert(train_avatar != null)
	
	var passenger_car_nodes: Array[Node] = train_avatar.find_children("Car_Passenger*")
	var cargo_car_nodes: Array[Node] = train_avatar.find_children("Car_Cargo*")
	for car in passenger_car_nodes:
		car.global_position = Vector2(99999.0, 99999.0)
	for car in cargo_car_nodes:
		car.global_position = Vector2(99999.0, 99999.0)
		
	# NOTE: almost exactly the same logic for passenger as cargo
	var off_x: float = 0
	for car_index in TrainState.passenger_car_count:
		var car: Node = passenger_car_nodes[car_index]
		assert(car != null)
		var connector: Node = car.get_node("ConnectPosition")
		assert(connector != null)
		off_x -= connector.position.x
		car.position = Vector2(off_x, 0.0)
		
		var avatars: Array[Node] = car.find_children("PersonAvatar*", "", false)
		for avatar in avatars:
			avatar.visible = false
			avatar.process_mode = Node.PROCESS_MODE_DISABLED
		for car_passenger_index in TrainState.max_passengers_per_car:
			var train_passenger_index: int = car_index * TrainState.max_passengers_per_car + car_passenger_index
			var slot_person: ID.Person = TrainState.passenger_slots[train_passenger_index]
			if slot_person != ID.Person.DEFAULT:
				draw_person_avatar(avatars[car_passenger_index], slot_person)
	for car_index in TrainState.cargo_car_count:
		var car: Node = cargo_car_nodes[car_index]
		assert(car != null)
		var connector: Node = car.get_node("ConnectPosition")
		assert(connector != null)
		off_x -= connector.position.x
		car.position = Vector2(off_x, 0.0)

func draw_person_avatar(avatar: Node, person_id: ID.Person):
	var person: Person = ResourceData.people[person_id]
	avatar.visible = true
	avatar.process_mode = Node.PROCESS_MODE_INHERIT
	# train car avatars are reused per slot, so tell the avatar who it is now
	avatar.person_id = person_id
	var sprite_node = avatar.get_node("Sprite2D")
	assert(sprite_node != null)
	sprite_node.texture = person.default_texture

func debug_text() -> String:
	var text: String = "Mode: " + GameMode.keys()[mode]
	return text
