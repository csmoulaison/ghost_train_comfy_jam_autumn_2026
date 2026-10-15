extends Node

@onready var music_player_1: AudioStreamPlayer = get_tree().current_scene.get_node("MusicPlayer1")
@onready var music_player_2: AudioStreamPlayer = get_tree().current_scene.get_node("MusicPlayer2")
@onready var chit_player: AudioStreamPlayer = get_tree().current_scene.get_node("ChitPlayer")
@onready var dialogue_sound_player: AudioStreamPlayer = get_tree().current_scene.get_node("DialogueSoundPlayer")
@onready var train_sound_player_1: AudioStreamPlayer = get_tree().current_scene.get_node("TrainSoundPlayer1")
@onready var train_sound_player_2: AudioStreamPlayer = get_tree().current_scene.get_node("TrainSoundPlayer2")

var music_base_volume

func _ready() -> void:
	assert(music_player_1 != null)
	assert(music_player_2 != null)
	assert(chit_player != null)
	assert(dialogue_sound_player != null)
	assert(train_sound_player_1 != null)
	assert(train_sound_player_2 != null)
	
	train_sound_player_1.stream = train_sound_player_1.exterior
	train_sound_player_1.play(0.0)
	music_player_1.stream = music_player_1.intro_music
	music_player_1.play(0.0)

func play(stream: AudioStream, player: AudioStreamPlayer):
	player.stream = stream
	player.play()

func play_offset_from_end(stream: AudioStream, player: AudioStreamPlayer, offset: float):
	player.stream = stream
	player.play(stream.get_length() - offset)

func set_volume(volume_linear: float, player: AudioStreamPlayer):
	# TODO(modulate)
	player.volume_linear = volume_linear
