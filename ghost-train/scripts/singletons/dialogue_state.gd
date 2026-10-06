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

## The player picked Accept or Decline on the current line's prompt. Accepting
## sets the line's flag and emits its event. Either answer then moves on: to
## that answer's chain if the line has one, otherwise to the next line.
func answer_prompt(accepted: bool) -> void:
	if not is_active(): return
	if not current_line.has_prompt():
		push_error("Answer Prompt: the current line has no prompt!")
		return

	var line: DialogueLine = current_line
	if accepted and line.prompt_flag != ID.Flag.DEFAULT:
		GameState.flags[line.prompt_flag] = true

	var answer_chain: DialogueChain = line.accept_chain if accepted else line.decline_chain
	if answer_chain != null and answer_chain.lines.is_empty():
		push_error("Answer Prompt: the chain for this answer has no lines!")
		answer_chain = null

	if answer_chain != null:
		# swap chains without ending the dialogue, so the overlay stays up. From
		# here on this is the chain that ends, and the post_event that fires.
		current_chain = answer_chain
		_set_line(0)
	else:
		advance()

	# emitted after moving on, so if that was the end of the dialogue a
	# listener is free to start another chain straight away
	if accepted and line.prompt_event != ID.Event.DEFAULT:
		EventBus.event_signal.emit(line.prompt_event, 0)
		
	# TODO(now): for now, I'm putting boarding passenger right inline here,
	# which might be all we need for prompts really, we'll see. I'm just
	# using the person id from the line itself.
	if accepted:
		TrainState.try_board_passenger(line.person)

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
