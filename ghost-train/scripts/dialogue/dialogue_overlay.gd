extends CanvasLayer

## The visual side of dialogue. DialogueState decides which line we're on; this
## scene prints that line and tells DialogueState when the player wants the
## next one.

@onready var dialogue_panel: DialoguePanel = %DialoguePanel
@onready var dialogue_text: RichTextLabel = %DialogueText
@onready var speaker_name_label: Label = %SpeakerNameText
@onready var speaker_image: TextureRect = %SpeakerImage
@onready var next_marker: TextureRect = %NextMarker

@onready var prompt_panel: DialoguePanel = %PromptPanel
@onready var prompt_text: RichTextLabel = %PromptText
@onready var prompt_accept_button: Button = %PromptAcceptButton
@onready var prompt_decline_button: Button = %PromptDeclineButton

@onready var background: ColorRect = %Background

const SECONDS_PER_CHARACTER: float = 0.03
const DEBOUNCE_TIME: float = 0.25
const MARKER_FADE_TIME: float = 0.15

const TEST_CHAIN: DialogueChain = preload("res://resources/dialogue_chains/test_dialogue.tres")

#var _is_line_printing: bool = false

enum DialogueLineState {
	PRINTING, # the text is still appearing
	PROMPTING, # the prompt is up, waiting for Accept / Decline
	ANSWERED, # an answer was picked, the prompt is on its way out
	FINISHED, # the text is all there, waiting for the player to continue
}
var _dialogue_line_state: DialogueLineState = DialogueLineState.FINISHED
var _line_tween: Tween
var _marker_tween: Tween
var _debounce_until_msec: int = 0

func _ready() -> void:
	initialize()
	background.gui_input.connect(_on_surface_gui)
	prompt_accept_button.pressed.connect(_on_prompt_button_pressed.bind(true))
	prompt_decline_button.pressed.connect(_on_prompt_button_pressed.bind(false))
	# hovering a button focuses it too, so the mouse and the keyboard can't
	# highlight different buttons at the same time
	prompt_accept_button.mouse_entered.connect(prompt_accept_button.grab_focus)
	prompt_decline_button.mouse_entered.connect(prompt_decline_button.grab_focus)
	DialogueState.dialogue_started.connect(_on_dialogue_started)
	DialogueState.line_changed.connect(read_line)
	DialogueState.dialogue_ended.connect(_on_dialogue_ended)

func _unhandled_input(event: InputEvent) -> void:
	# DEBUG ONLY
	if OS.is_debug_build() and event is InputEventKey:
		if event.pressed and event.keycode == KEY_F2:
			DialogueState.start_dialogue(TEST_CHAIN)

	# keyboard / gamepad version of clicking the background
	#if DialogueState.is_active() and event.is_action_pressed("ui_accept"):
		#get_viewport().set_input_as_handled()
		#_on_continue_pressed()

## Hides everything and resets back to "no dialogue playing".
func initialize():
	visible = false
	dialogue_panel.hide_instantly()
	dialogue_text.text = ""
	if _marker_tween:
		_marker_tween.kill()
	next_marker.modulate.a = 0.0
	_hide_prompt()
	prompt_text.text = ""
	_dialogue_line_state = DialogueLineState.FINISHED
	if _line_tween:
		_line_tween.kill()

## signal functions

func _on_dialogue_started(_chain: DialogueChain):
	visible = true
	dialogue_panel.play_enter()

func _on_dialogue_ended(_chain: DialogueChain):
	if _line_tween:
		_line_tween.kill()
	# only when something else ended the dialogue while the prompt was up
	if prompt_panel.visible:
		prompt_panel.play_exit().tween_callback(_hide_prompt)
	dialogue_panel.play_exit().tween_callback(initialize)

func _on_surface_gui(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_continue_pressed()

## The player clicked / pressed accept: first press finishes printing the line,
## the next press moves on. While a prompt is up only its buttons do anything.
func _on_continue_pressed():
	if not DialogueState.is_active(): return
	if not _can_continue(): return

	if _dialogue_line_state == DialogueLineState.PRINTING:
		_finish_current_line()
		_debounce()
	elif _dialogue_line_state == DialogueLineState.FINISHED:
		DialogueState.advance()

func _on_prompt_button_pressed(accepted: bool):
	if _dialogue_line_state != DialogueLineState.PROMPTING: return
	if not _can_continue(): return

	# the answer is only passed on once the prompt has left, so the next line
	# doesn't start printing underneath it
	_dialogue_line_state = DialogueLineState.ANSWERED
	prompt_panel.play_exit().tween_callback(_on_prompt_closed.bind(accepted))

func _on_prompt_closed(accepted: bool):
	_hide_prompt()
	DialogueState.answer_prompt(accepted)

## private functions

func read_line(line: DialogueLine):
	if _line_tween:
		_line_tween.kill()
	_dialogue_line_state = DialogueLineState.PRINTING
	_fade_marker(0.0)

	var person: Person = ResourceData.people[line.person]
	speaker_name_label.text = person.name
	speaker_image.texture = person.default_texture if person.default_texture != null else null
	dialogue_text.text = line.text
	dialogue_text.visible_ratio = 0.0
	var duration: float = dialogue_text.get_total_character_count() * SECONDS_PER_CHARACTER
	_line_tween = create_tween()
	_line_tween.tween_property(dialogue_text, "visible_ratio", 1.0, duration)
	_line_tween.tween_callback(_finish_current_line)

	_debounce()

## Called both when the line finishes printing on its own and when the player
## skips ahead.
func _finish_current_line():
	if _line_tween:
		_line_tween.kill()
	dialogue_text.visible_ratio = 1.0

	var line: DialogueLine = DialogueState.current_line
	if line.has_prompt():
		_show_prompt(line)
	else:
		_dialogue_line_state = DialogueLineState.FINISHED
		_fade_marker(1.0)

func _show_prompt(line: DialogueLine):
	_dialogue_line_state = DialogueLineState.PROMPTING
	prompt_text.text = line.prompt_text
	prompt_panel.visible = true
	prompt_panel.play_enter()
	# so keyboard / gamepad can pick an answer
	prompt_accept_button.grab_focus()
	# a double click to skip the printing shouldn't be able to pick an answer
	_debounce()

## The panel has to be invisible as well as faded out, or its buttons would
## still catch clicks.
func _hide_prompt():
	prompt_panel.visible = false
	prompt_panel.hide_instantly()

# utility

func _fade_marker(alpha: float):
	if _marker_tween:
		_marker_tween.kill()
	_marker_tween = create_tween()
	_marker_tween.tween_property(next_marker, "modulate:a", alpha, MARKER_FADE_TIME)

func _can_continue() -> bool:
	return Time.get_ticks_msec() >= _debounce_until_msec

## Ignore continue presses for a moment, so a double click can't skip a line.
func _debounce():
	_debounce_until_msec = Time.get_ticks_msec() + int(DEBOUNCE_TIME * 1000)
