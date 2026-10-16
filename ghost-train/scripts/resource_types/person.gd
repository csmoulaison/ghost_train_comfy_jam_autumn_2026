class_name Person extends Resource

@export var name: String
@export var starting_location: ID.Location
@export var default_texture: Texture2D
@export var conditional_texture_packs: Array[PersonTexturePack] = []
@export var default_texture_pack: PersonTexturePack = null
@export var sprite_scale: float = 1.0

@export var conditional_interact_dialogue: Array[DialogueLine]
@export var default_interact_dialogue: DialogueLine
@export var desired_location: ID.Location
@export var reached_location_dialogue: DialogueLine
@export var no_room_on_train_dialogue: DialogueLine
@export var found_jackokid_dialogue: DialogueLine
