class_name Person extends Resource

@export var name: String
@export var starting_location: ID.Location
@export var default_texture: Texture2D
@export var texture_pack: PersonTexturePack
@export var sprite_scale: float = 1.0

@export var conditional_interact_dialogue: Array[DialogueLine]
@export var default_interact_dialogue: DialogueLine
@export var desired_location: ID.Location
@export var reached_location_dialogue: DialogueLine
