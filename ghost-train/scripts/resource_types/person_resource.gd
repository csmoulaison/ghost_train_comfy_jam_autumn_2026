class_name Person extends Resource

@export var id: ID.Person
@export var name: String
@export var starting_location: ID.Location
# TODO: These two fields prefixed with default_ are going to need to be more
# complex in the future as we get a handle on the design. There will probably be
# more than 1 texture per character, and more than 1 dialogue chain.
@export var default_texture: Texture2D # TODO: is this the right resource type?
@export var default_dialogue_chain: DialogueChain
