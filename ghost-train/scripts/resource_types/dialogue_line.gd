class_name DialogueLine extends Resource

@export var person: ID.Person
@export var text: String

@export_group("Prompt")
## Fill this in to ask the player Accept / Decline once the line has printed.
## Leave it empty for a normal line.
@export var prompt_text: String
## Set to true when the player accepts.
@export var prompt_flag: ID.Flag
## Emitted as soon as the player accepts.
@export var prompt_event: ID.Event
## Played after Accept, in place of the rest of this chain. Leave empty to
## carry on to the next line.
@export var accept_chain: DialogueChain
## Played after Decline, in place of the rest of this chain. Leave empty to
## carry on to the next line.
@export var decline_chain: DialogueChain

func has_prompt() -> bool:
	return prompt_text != ""
