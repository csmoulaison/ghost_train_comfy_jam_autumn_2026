extends Node

enum GameMode {
	TRAVEL,
	DESTINATION,
	MAP,
	MAIN_MENU,
	PAUSE_MENU,
}

# WARNING: IF YOU ADD A SCENE NODE HERE, UPDATE remove_all_scenes() FUNCTION
@onready var travel_scene: Node = get_tree().root.find_child("TravelScene")
@onready var destination_scene: Node = get_tree().root.find_child("DestinationScene")
@onready var map_scene: Node = get_tree().root.find_child("MapScene")
@onready var main_menu_scene: Node = get_tree().root.find_child("MainMenuScene")
@onready var pause_menu_scene: Node = get_tree().root.find_child("PauseMenuScene")

var mode: GameMode = GameMode.DESTINATION

func _ready() -> void:
	# TODO: start at main menu
	switch_mode(GameMode.DESTINATION)

func switch_mode(new_mode: GameMode):
	mode = new_mode
	
	# pausing has unique logic here
	if(mode == GameMode.PAUSE_MENU):
		# TODO: set some paused state somewhere
		add_scene(pause_menu_scene)
		return
		
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
			pass

# removes scenes from the root's children, but keeps their state in memory for
# retrieval later.
func remove_all_scenes():
	var root = get_tree().root
	root.remove_child(travel_scene)
	root.remove_child(destination_scene)
	root.remove_child(map_scene)
	root.remove_child(main_menu_scene)
	root.remove_child(pause_menu_scene)

# adds a node to the root's children, restoring whatever state it had before it
# was removed (unless it was screwed with somehow in the interim)
func add_scene(scene_node: Node):
	var root = get_tree().root
	root.add_child(scene_node)
