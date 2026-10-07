extends Node

var current_cinematic: ID.Cinematic
var t: float = 0.0
var loaded_scene: Node = null

# state specific to certain cinematics
var intro_train: Node = null

func _process(dt: float):
	match current_cinematic:
		ID.Cinematic.INTRO_1:
			assert(intro_train != null)
			t += dt
			intro_train.position.x = -700.0 + t_range(t, 0.0, 4.0) * 2400.0
			if t > 1.0:
				intro_train = null
				stop_cinematic()
				ModeState.arrive_at_destination(ID.Location.PUMPKIN_PATCH)

func start_cinematic(cinematic_id: ID.Cinematic, no_mode: bool):
	assert(current_cinematic == ID.Cinematic.DEFAULT, "Started a cinematic without calling stop_cinematic() on an old one, or you are really doing some fucking shenanigans.")
	current_cinematic = cinematic_id
	t = 0.0
	if no_mode:
		ModeState.switch_mode(ModeState.GameMode.ONLY_CINEMATIC)
	
	# initialize state for particular cinematics
	match current_cinematic:
		ID.Cinematic.INTRO_1:
			var scene = load("res://scenes/intro_1.tscn")
			assert(scene != null)
			loaded_scene = scene.instantiate()
			assert(loaded_scene != null)
			intro_train = loaded_scene.get_node("TrainAvatar")
			assert(intro_train != null)
			get_tree().current_scene.add_child(loaded_scene)

func stop_cinematic():
	loaded_scene.queue_free()
	current_cinematic = ID.Cinematic.DEFAULT
	
func debug_text() -> String:
	if intro_train != null:
		return "TRAIN X: " + str(intro_train.position.x)
	return ""

# helpers on t
func t_range(rt: float, t1: float, t2: float):
	var r = t2 - t1
	var offset = rt - t1
	return offset * (1.0 / r)

func t_in_range(rt: float, t1: float, t2: float):
	var r = t_range(rt, t1, t2)
	if r < 0.0 || r > 1.0:
		return false
	return true

func t_range_clamped(rt: float, t1: float, t2: float):
	return clamp(t_range(rt, t1, t2), 0.0, 1.0)
