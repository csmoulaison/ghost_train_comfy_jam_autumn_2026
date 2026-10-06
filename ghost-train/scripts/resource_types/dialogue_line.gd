class_name DialogueLine extends Resource

@export var person: ID.Person = ID.Person.DEFAULT
@export var text: String = ""
@export var conditions: Array[StateCondition] = []
@export var pre_effects: Array[StateEffect] = []
@export var post_effects: Array[StateEffect] = []
@export var conditional_next_lines: Array[DialogueLine] = []
@export var default_next_line: DialogueLine = null

@export_group("Prompt")
## Fill this in to ask the player Accept / Decline once the line has printed.
## Leave it empty for a normal line.
@export var prompt_text: String
@export_subgroup("On Accept")
@export var accept_effects: Array[StateEffect] = []
@export var conditional_accept_lines: Array[DialogueLine] = []
@export var default_accept_line: DialogueLine
@export_subgroup("On Decline")
@export var decline_effects: Array[StateEffect] = []
@export var conditional_decline_lines: Array[DialogueLine] = []
@export var default_decline_line: DialogueLine

## TODO(now): DEPRECATE. Set to true when the player accepts.
#@export var prompt_flag: ID.Flag
## TODO(now): DEPRECATE. Emitted as soon as the player accepts.
#@export var prompt_event: ID.Event
## TODO(now): DEPRECATE. Played after Accept, in place of the rest of this chain. Leave empty to
## carry on to the next line.
#@export var accept_chain: DialogueChain
## TODO(now): DEPRECATE. Played after Decline, in place of the rest of this chain. Leave empty to
## carry on to the next line.
#@export var decline_chain: DialogueChain

func has_prompt() -> bool:
	return prompt_text != ""
