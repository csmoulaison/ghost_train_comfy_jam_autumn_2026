extends Node

@onready var fade_sprite: Sprite2D = get_tree().current_scene.get_node("FadeOverlay/Sprite")
@onready var title_label: Label = get_tree().current_scene.get_node("TitleOverlay/Label")
@onready var camera: Camera2D = get_tree().current_scene.get_node("Camera")

var depart_train_length: float = 6.0
var arrive_train_length: float = 7.0
var exit_travel_length: float = 1.0

var current_cinematic: ID.Cinematic
var t: float = 0.0
var loaded_scene: Node = null

# state specific to certain cinematics
var intro_train: Node = null
var intro_button: Node = null
var intro_text: Node = null
var intro_credits: Node = null
var train_arrival_point: float = 0.0
var arriving_at_destination_with_fade: bool

func _ready():
	assert(fade_sprite != null)
	assert(camera != null)
	assert(title_label != null)
	fade_sprite.modulate.a = 0.0
	title_label.modulate.a = 0.0
	EventBus.event_signal.connect(_on_event)

func _on_event(event: ID.Event, _arg: int):
	if event == ID.Event.GET_ON_TRAIN_WITH_GRIMM:
		# TODO(now): very much untested
		MapLocation.select_node(ID.Location.GRAVEYARD, ID.Road.GRAVEYARD_TO_FARMERS_MARKET, false)
		ModeState.depart_to_travel()
	else: if event == ID.Event.GO_TO_END_TRAIN:
		GameState.flags[ID.Flag.ON_END_TRAIN] = true
		MapLocation.select_node(ID.Location.FARMERS_MARKET, ID.Road.GRAVEYARD_TO_FARMERS_MARKET, false)
		ModeState.depart_to_travel()
	else: if event == ID.Event.END_GAME:
		start_cinematic(ID.Cinematic.END_GAME, false)

func _physics_process(dt: float):
	if DebugOverlay.active: dt *= 25.0
	t += dt
	match current_cinematic:
		ID.Cinematic.INTRO_1:
			intro_train.position.x = 2706.0 - t_range_cubic_clamped(t, 7.0, 0.0) * 2000.0
			intro_button.modulate.a = t_range_clamped(t, 0.5, 0.0)
			intro_text.modulate.a = t_range_clamped(t, 1.0, 0.5)
			intro_credits.modulate.a = t_range_clamped(t, 2.5, 3.5) * t_range_clamped(t, 5.5, 4.5) 
			fade_sprite.modulate.a = t_range_clamped(t, 5.0, 6.0)
			GameState.flags[ID.Flag.GHOST_TRAIN_DESTINATION_AVATAR] = true
			AudioState.set_volume(t_range_clamped(t, 3.0, 0.0), AudioState.music_player_1)
			AudioState.set_volume(0.33 + t_range_clamped(t, 1.0, 4.0) * 0.66, AudioState.train_sound_player_1)
			if t > 6.0:
				intro_train = null
				stop_cinematic()
				ModeState.arrive_at_destination(ID.Location.PUMPKIN_PATCH)
				arriving_at_destination_with_fade = true
			
		ID.Cinematic.DEPART_TO_TRAVEL:
			GameState.flags[ID.Flag.GHOST_TRAIN_DESTINATION_AVATAR] = true
			TrainState.visible_velocity = 0.0
			
			if t_bang_threshold(t, 0.1, dt): AudioState.play(AudioState.train_sound_player_2.depart_sound, AudioState.train_sound_player_2)
			AudioState.set_volume(t_range_clamped(t, depart_train_length - 0.1, depart_train_length - 4.0), AudioState.music_player_1)
			if t_bang_threshold(t, 4.5, dt): AudioState.play(AudioState.train_sound_player_1.exterior, AudioState.train_sound_player_1)
			AudioState.set_volume(t_range_clamped(t, 4.5, 5.5), AudioState.train_sound_player_1)
			
			if t < depart_train_length - 1.0:
				ModeState.train_avatar.position.x = train_arrival_point + 960.0 - t_range_cubic_clamped(t, depart_train_length, 0.0) * 960.0
				fade_sprite.modulate.a = t_range_clamped(t, depart_train_length - 2.0, depart_train_length - 1.0)
			if t_bang_threshold(t, depart_train_length - 1.0, dt):
				if GameState.flags[ID.Flag.ON_END_TRAIN]:
					TrainState.passenger_car_count = 9
					if TrainState.total_cargo_sold[ID.Cargo.HONEY] > 0: TrainState.try_board_passenger(ID.Person.BEES)
					if GameState.people_locations[ID.Person.CROW] == ID.Location.FARMERS_MARKET: TrainState.try_board_passenger(ID.Person.CROW)
					TrainState.try_board_passenger(ID.Person.VAMPIRE)
					if GameState.flags[ID.Flag.GAVE_BOOK_TO_TREE]: TrainState.try_board_passenger(ID.Person.OL_APPLE)
					TrainState.try_board_passenger(ID.Person.WITCH)
					TrainState.try_board_passenger(ID.Person.JACKO)
					TrainState.try_board_passenger(ID.Person.SCARECROW)
					if GameState.people_locations[ID.Person.JACKOKID_2] == ID.Location.PUMPKIN_PATCH: TrainState.try_board_passenger(ID.Person.JACKOKID_2)
					if GameState.people_locations[ID.Person.JACKOKID_1] == ID.Location.PUMPKIN_PATCH: TrainState.try_board_passenger(ID.Person.JACKOKID_1)
					if GameState.people_locations[ID.Person.JACKOKID_4] == ID.Location.PUMPKIN_PATCH: TrainState.try_board_passenger(ID.Person.JACKOKID_4)
					if GameState.people_locations[ID.Person.JACKOKID_3] == ID.Location.PUMPKIN_PATCH: TrainState.try_board_passenger(ID.Person.JACKOKID_3)
					if GameState.people_locations[ID.Person.JACKOKID_6] == ID.Location.PUMPKIN_PATCH: TrainState.try_board_passenger(ID.Person.JACKOKID_6)
					if GameState.people_locations[ID.Person.JACKOKID_5] == ID.Location.PUMPKIN_PATCH: TrainState.try_board_passenger(ID.Person.JACKOKID_5)
					if GameState.people_locations[ID.Person.JACKOKID_8] == ID.Location.PUMPKIN_PATCH: TrainState.try_board_passenger(ID.Person.JACKOKID_8)
					if GameState.people_locations[ID.Person.JACKOKID_7] == ID.Location.PUMPKIN_PATCH: TrainState.try_board_passenger(ID.Person.JACKOKID_7)
				ModeState.switch_mode(ModeState.GameMode.TRAVEL)
				TrainState.current_location = ID.Location.DEFAULT
				var road: Road = ResourceData.roads[TrainState.current_road]
				ModeState.load_subscene(ModeState.travel_subscene_parent, road.subscene_path)
				ParallaxState.begin_parallax()
				for index in ID.Cargo.CARGO_COUNT:
					GameState.cargo_cooldowns[index] -= 1
			if t > depart_train_length - 1.0:
				var zoom = 1.1 + t_range_cubic_clamped(t, depart_train_length - 1.0, depart_train_length) * 0.1
				camera.zoom = Vector2(zoom, zoom)
				fade_sprite.modulate.a = t_range_clamped(t, depart_train_length, depart_train_length - 1.0)
				GameState.flags[ID.Flag.GHOST_TRAIN_DESTINATION_AVATAR] = false
			if t > depart_train_length:
				stop_cinematic()
		ID.Cinematic.EXIT_TRAVEL:
			fade_sprite.modulate.a = t_range_clamped(t, 0.0, exit_travel_length - 0.0)
			if t > exit_travel_length:
				arriving_at_destination_with_fade = true
				stop_cinematic()
				ModeState.arrive_at_destination(ModeState.cached_arrival_destination)
		ID.Cinematic.ARRIVE_AT_DESTINATION:
			var zoom: float = 1.0
			if arriving_at_destination_with_fade:
				fade_sprite.modulate.a = t_range_clamped(t, 1.4, 0.5)
				zoom = 1.2 - t_range_cubic_clamped(t, 0.0, arrive_train_length) * 0.2
			camera.zoom = Vector2(zoom, zoom)
			
			var location: Location = ResourceData.locations[TrainState.current_location]
			title_label.text = location.name
			title_label.modulate = location.color
			if t < 2.5: title_label.modulate.a = t_range_clamped(t, 1.5, 2.5)
			else: title_label.modulate.a = t_range_clamped(t, arrive_train_length - 0.0, arrive_train_length - 0.8)
			
			if t_bang_threshold(t, 0.2, dt): AudioState.play(AudioState.train_sound_player_2.arrival_sound, AudioState.train_sound_player_2)
			if t_bang_threshold(t, 4.2, dt): AudioState.play_offset_from_end(location.music, AudioState.music_player_1, 0.66)
			AudioState.set_volume(t_range_clamped(t, 1.0, 0.0), AudioState.train_sound_player_1)
			AudioState.set_volume(t_range_clamped(t, 4.2, 5.2), AudioState.music_player_1)
			
			GameState.flags[ID.Flag.GHOST_TRAIN_DESTINATION_AVATAR] = true
			ModeState.train_avatar.position.x = -400.0 + t_range_cubic_clamped(t, 0.0, arrive_train_length) * (train_arrival_point + 400.0)
			if t > arrive_train_length + 1.0:
				stop_cinematic()
				GameState.flags[ID.Flag.GHOST_TRAIN_DESTINATION_AVATAR] = false
				if ModeState.cached_arrival_dialogue != null:
					DialogueState.open_dialogue([], ModeState.cached_arrival_dialogue)
					ModeState.cached_arrival_dialogue = null
		ID.Cinematic.END_GAME:
			AudioState.set_volume(t_range_clamped(t, 2.0, 1.0), AudioState.train_sound_player_1)
			if t < 3.0: fade_sprite.modulate.a = t_range_clamped(t, 0.0, 2.0)
			if t_bang_threshold(t, 3.0, dt): ModeState.switch_mode(ModeState.GameMode.END_SCREEN)
			if t > 3.0: fade_sprite.modulate.a = t_range_clamped(t, 5.0, 3.0)
			if t_bang_threshold(t, 3.5, dt): AudioState.play_offset_from_end(AudioState.music_player_1.intro_music, AudioState.music_player_1, -0.66)
			if t > 3.5: AudioState.set_volume(t_range_clamped(t, 3.5, 4.5) * 0.75, AudioState.music_player_1)
			if t > 5.0: stop_cinematic()
		ID.Cinematic.TMP_ENDING:
			pass

func start_cinematic(cinematic_id: ID.Cinematic, no_mode: bool):
	assert(current_cinematic == ID.Cinematic.DEFAULT, "Started a cinematic without calling stop_cinematic() on an old one, or you are really doing some fucking shenanigans.")
	current_cinematic = cinematic_id
	t = 0.0
	if no_mode:
		ModeState.switch_mode(ModeState.GameMode.ONLY_CINEMATIC)

	# initialize state for particular cinematics
	match current_cinematic:
		ID.Cinematic.INTRO_1:
			intro_train = get_tree().current_scene.get_node("MainMenuScene/Train")
			intro_button = get_tree().current_scene.get_node("MainMenuScene/PressStart")
			intro_text = get_tree().current_scene.get_node("MainMenuScene/Title")
			intro_credits = get_tree().current_scene.get_node("MainMenuScene/IntroCredits")
			assert(intro_train != null)
			assert(intro_button != null)
			assert(intro_text != null)
			assert(intro_credits != null)
		ID.Cinematic.DEPART_TO_TRAVEL:
			TrainState.visible_velocity = 0.0
			pass
		ID.Cinematic.ARRIVE_AT_DESTINATION:
			train_arrival_point = ModeState.train_avatar.position.x
			ModeState.train_avatar.position.x = -1200.0

func stop_cinematic():
	if loaded_scene != null:
		loaded_scene.queue_free()
		loaded_scene = null
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

func t_bang_threshold(rt: float, threshold: float, dt: float):
	if rt - dt < threshold and rt >= threshold: return true
	return false

func t_range_cubic_clamped(rt: float, t1: float, t2: float):
	var clamped: float = t_range_clamped(rt, t1, t2)
	return clamped * (2.0 - clamped)
