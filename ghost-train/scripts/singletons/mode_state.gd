extends Node

enum GameMode {
	TRAVEL,
	DESTINATION,
	MAP,
	MAIN_MENU,
	PAUSE_MENU,
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

func _ready() :
	assert(travel_scene != null)
	assert(travel_subscene_parent != null)
	assert(destination_scene != null)
	assert(destination_subscene_parent != null)
	assert(map_scene != null)
	assert(main_menu_scene != null)
	assert(pause_menu_scene != null)

func _process(dt: float):
	# NOTE: This is done so that every node's _ready function runs on game
	# startup. Calling enter_destination_mode in our _ready would precede that
	# happening in the case of all non autoload singletons, and in the case of
	# singletons, forces the brittle constraint of ModeState being at the bottom
	# of the Project Settings->Globals->Autoload list
	if !initialized:
		initialized = true
		# TODO: start at main menu, presumably
		enter_destination_mode(ID.Location.GRAVEYARD)
	
func enter_destination_mode(location_id: ID.Location):
	switch_mode(GameMode.DESTINATION)
	var location: Location = ResourceData.locations[location_id]
	TrainState.current_location = location_id
	TrainState.next_location = ID.Location.DEFAULT
	TrainState.current_road = ID.Road.DEFAULT
	load_subscene(destination_subscene_parent, location.subscene_path)
	update_scene_avatars(loaded_scene_instance)
	
func enter_travel_mode():
	switch_mode(GameMode.TRAVEL)
	TrainState.current_location = ID.Location.DEFAULT
	var road: Road = ResourceData.roads[TrainState.current_road]
	load_subscene(travel_subscene_parent, road.subscene_path)
	update_scene_avatars(travel_scene)
	
func enter_map_mode():
	switch_mode(GameMode.MAP)
	MapState.init_visual_state()

func switch_mode(new_mode: GameMode):
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
			assert(false, "Why are we entering the main menu from the game? The rest of the game's programming doesn't account for that very well.")
		GameMode.PAUSE_MENU:
			assert(false, "Shouldn't call switch_mode with pause menu. Pausing doesn't remove other scenes, so it has its own logic.")

# removes scenes from the root's children, but keeps their state in memory for
# retrieval later.
func remove_all_scenes():
	scene_parent.remove_child(travel_scene)
	scene_parent.remove_child(destination_scene)
	scene_parent.remove_child(map_scene)
	scene_parent.remove_child(main_menu_scene)
	scene_parent.remove_child(pause_menu_scene)

# adds a node to the root's children, restoring whatever state it had before it
# was removed (unless it was screwed with somehow in the interim)
func add_scene(scene_node: Node):
	scene_parent.add_child(scene_node)

func load_subscene(parent: Node, subscene_path: String):
	if loaded_scene_instance != null:
		loaded_scene_instance.queue_free()
		loaded_scene_instance = null
	var scene: PackedScene = load(subscene_path)
	assert(scene != null, "Ask Conner: Couldn't load subscene '" + subscene_path + "'. Has it been set?")
	loaded_scene_instance = scene.instantiate()
	assert(loaded_scene_instance != null)
	parent.add_child(loaded_scene_instance)

func update_scene_avatars(scene: Node):
	# TODO: There is no test here for testing if there isn't an avatar defined 
	# where there should be. Not great.
	var avatars: Array[Node] = scene.find_children("PersonAvatar*")
	for avatar in avatars:
		avatar.visible = false
		avatar.process_mode = Node.PROCESS_MODE_DISABLED
	for id in ID.Person.PERSON_COUNT:
		var matching_avatar: Node = null
		for avatar in avatars:
			if avatar.person_id != id:
				continue
			if ModeState.mode == GameMode.DESTINATION:
				if avatar.at_destination_but_on_train and GameState.people_on_train[id]:
					matching_avatar = avatar
					break
				else: if !avatar.at_destination_but_on_train and GameState.people_locations[id] == TrainState.current_location:
					matching_avatar = avatar
					break
			else: if ModeState.mode == GameMode.TRAVEL:
				if GameState.people_on_train[id]:
					matching_avatar = avatar
					break
		if matching_avatar != null:
			var person: Person = ResourceData.people[id]
			matching_avatar.visible = true
			matching_avatar.process_mode = Node.PROCESS_MODE_INHERIT
			var sprite_node = matching_avatar.get_node("Sprite2D")
			assert(sprite_node != null)
			sprite_node.texture = person.default_texture

func debug_text() -> String:
	var text: String = "Mode: " + GameMode.keys()[mode]
	return text
