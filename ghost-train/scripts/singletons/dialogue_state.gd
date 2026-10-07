extends Node

## The data side of dialogue: which line is playing.
## The dialogue overlay listens to these signals and does all the visuals, so
## nothing in here should know about nodes, tweens or input.
##
## To play a line from anywhere: DialogueState.start_dialogue(line)

signal dialogue_started(line: DialogueLine)
signal line_changed(line: DialogueLine)
signal dialogue_ended(line: DialogueLine)

var current_line: DialogueLine

func is_active() -> bool:
	return current_line != null

func open_dialogue(conditional_lines: Array[DialogueLine], default_line: DialogueLine) -> void:
	if is_active():
		push_error("Start Dialogue Line: a dialogue line is already playing!")
		return
	# TODO(now): is this control flow okay?
	var started_line: DialogueLine = try_start_line_from_conditional_list(conditional_lines, default_line, [])
	if started_line != null: 
		dialogue_started.emit(started_line)

## Returns the dialogue line that was chosen.
func try_start_line_from_conditional_list(conditional_lines: Array[DialogueLine], default_line: DialogueLine, post_effects_from_previous: Array[StateEffect]) -> DialogueLine:
	StateEffect.fire_list(post_effects_from_previous)
	# NOTE: default_line must be set, or the dialogue will close, even if
	# there are conditional_lines.
	if default_line == null:
		close_dialogue()
		return null
		
	var line_to_start: DialogueLine = default_line
	for line in conditional_lines:
		if StateCondition.check_list(line.conditions):
			line_to_start = line
			break
	current_line = line_to_start
	StateEffect.fire_list(current_line.pre_effects)
	line_changed.emit(current_line)
	return line_to_start

## Moves on to the next line, or ends the dialogue if that was the last one.
func advance() -> void:
	if not is_active(): return
	try_start_line_from_conditional_list(current_line.conditional_next_lines, current_line.default_next_line, current_line.post_effects)

## The player picked Accept or Decline on the current line's prompt.
func answer_prompt(accepted: bool) -> void:
	if not is_active(): return
	if not current_line.has_prompt():
		push_error("Answer Prompt: the current line has no prompt!")
		return

	var line: DialogueLine = current_line
	if accepted:
		try_start_line_from_conditional_list(line.conditional_accept_lines, line.default_accept_line, line.accept_effects)
	else:
		try_start_line_from_conditional_list(line.conditional_decline_lines, line.default_decline_line, line.decline_effects)
		
	# TODO(now): for now, I'm putting boarding passenger right inline here,
	# which might be all we need for prompts really, we'll see. I'm just
	# using the person id from the line itself.
	#if accepted:
	#	TrainState.try_board_passenger(line.person)

func close_dialogue() -> void:
	if not is_active(): return
	# clear our state before emitting, so a listener is free to start another
	# chain straight away
	var finished_line: DialogueLine = current_line
	current_line = null
	dialogue_ended.emit(finished_line)
