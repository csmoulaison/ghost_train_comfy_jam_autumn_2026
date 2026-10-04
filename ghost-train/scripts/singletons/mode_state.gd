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

var mode: GameMode = GameMode.DESTINATION

func _ready() -> void:
	assert(travel_scene != null)
	assert(travel_subscene_parent != null)
	assert(destination_scene != null)
	assert(destination_subscene_parent != null)
	assert(map_scene != null)
	assert(main_menu_scene != null)
	assert(pause_menu_scene != null)
	# TODO: start at main menu, presumably
	enter_destination_mode(ID.Location.GRAVEYARD)
	
func enter_destination_mode(location_id: ID.Location):
	var location: Location = ResourceData.locations[location_id]
	load_subscene(destination_subscene_parent, location.subscene_path)
	switch_mode(GameMode.DESTINATION)
	
func enter_travel_mode(road_id: ID.Road):
	var road: Road = ResourceData.roads[road_id]
	load_subscene(travel_subscene_parent, road.subscene_path)
	switch_mode(GameMode.TRAVEL)
	
func enter_map_mode():
	switch_mode(GameMode.MAP)

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
	# TODO: if perf is an issue, we can preload these for destinations
	var scene: PackedScene = load(subscene_path)
	assert(scene != null, "Ask Conner: Couldn't load subscene '" + subscene_path + "'. Has it been set?")
	var instance: Node = scene.instantiate()
	assert(instance != null)
	parent.add_child(instance)
