extends Node

## The data side of dialogue: which chain is playing and which line we're on.
## The dialogue overlay listens to these signals and does all the visuals, so
## nothing in here should know about nodes, tweens or input.
##
## To play a chain from anywhere: DialogueState.start_dialogue(chain)

signal dialogue_started(chain: DialogueChain)
signal line_changed(line: DialogueLine)
signal dialogue_ended(chain: DialogueChain)

var current_chain: DialogueChain
var current_line: DialogueLine

var _line_index: int = 0

func is_active() -> bool:
	return current_chain != null

func start_dialogue(chain: DialogueChain) -> void:
	if is_active():
		push_error("Start Dialogue: a dialogue chain is already playing!")
		return
	if chain == null or chain.lines.is_empty():
		push_error("Start Dialogue: dialogue chain has no lines!")
		return

	current_chain = chain
	dialogue_started.emit(chain)
	_set_line(0)

## Moves on to the next line, or ends the dialogue if that was the last one.
func advance() -> void:
	if not is_active(): return

	var next_index: int = _line_index + 1
	if next_index < current_chain.lines.size():
		_set_line(next_index)
	else:
		end_dialogue()

func end_dialogue() -> void:
	if not is_active(): return

	# clear our state before emitting, so a listener is free to start another
	# chain straight away
	var finished_chain: DialogueChain = current_chain
	current_chain = null
	current_line = null
	_line_index = 0

	dialogue_ended.emit(finished_chain)

	# ID.Event.DEFAULT is what an unset post_event exports as, so treat it as
	# "no event"
	if finished_chain.post_event != ID.Event.DEFAULT:
		EventBus.event_signal.emit(finished_chain.post_event, 0)

## private functions

func _set_line(index: int) -> void:
	_line_index = index
	current_line = current_chain.lines[index]
	line_changed.emit(current_line)
