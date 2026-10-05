extends CanvasLayer

## The visual side of dialogue. DialogueState decides which line we're on; this
## scene prints that line and tells DialogueState when the player wants the
## next one.

@onready var dialogue_panel: Panel = %DialoguePanel
@onready var dialogue_text: RichTextLabel = %DialogueText
@onready var next_marker: TextureRect = %NextMarker

@onready var prompt_panel: PanelContainer = %PromptPanel
@onready var prompt_text: RichTextLabel = %PromptText
@onready var prompt_accept_button: Button = %PromptAcceptButton
@onready var prompt_decline_button: Button = %PromptDeclineButton

@onready var background: ColorRect = %Background

const SECONDS_PER_CHARACTER: float = 0.03
const FADE_TIME: float = 0.2
const DEBOUNCE_TIME: float = 0.25

const TEST_CHAIN: DialogueChain = preload("res://resources/dialogue_chains/test_dialogue.tres")

var _is_line_printing: bool = false
var _line_tween: Tween
var _fade_tween: Tween
var _debounce_until_msec: int = 0

func _ready() -> void:
	initialize()
	background.gui_input.connect(_on_surface_gui)
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
	dialogue_panel.modulate.a = 0.0
	dialogue_text.text = ""
	next_marker.visible = false
	prompt_panel.visible = false
	prompt_panel.modulate.a = 0.0
	prompt_text.text = ""
	_is_line_printing = false
	if _line_tween:
		_line_tween.kill()

## signal functions

func _on_dialogue_started(_chain: DialogueChain):
	visible = true
	_fade_panel(1.0)

func _on_dialogue_ended(_chain: DialogueChain):
	if _line_tween:
		_line_tween.kill()
	_fade_panel(0.0)
	_fade_tween.tween_callback(initialize)

func _on_surface_gui(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_continue_pressed()

## The player clicked / pressed accept: first press finishes printing the line,
## the next press moves on.
func _on_continue_pressed():
	if not DialogueState.is_active(): return
	if not _can_continue(): return

	if _is_line_printing:
		_finish_current_line()
		_debounce()
	else:
		# TODO (prompt): if this line/chain should ask Accept / Decline, show
		# prompt_panel here instead of advancing, and advance from the button
		# signals. Needs a design decision first: is the prompt data on the
		# DialogueLine or on the DialogueChain? Once there are three states
		# (printing, waiting, prompting) swap _is_line_printing for an enum.
		DialogueState.advance()

## private functions

func read_line(line: DialogueLine):
	if _line_tween:
		_line_tween.kill()
	_is_line_printing = true
	next_marker.visible = false

	# TODO (speaker): add a name label + portrait TextureRect to the scene, then
	# set them here. The data is already reachable:
	#   var person: Person = ResourceData.people[line.person]
	#   person.name, person.default_texture

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
	_is_line_printing = false
	dialogue_text.visible_ratio = 1.0
	next_marker.visible = true

func _fade_panel(target_alpha: float):
	if _fade_tween:
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(dialogue_panel, "modulate:a", target_alpha, FADE_TIME)

# utility

func _can_continue() -> bool:
	return Time.get_ticks_msec() >= _debounce_until_msec

## Ignore continue presses for a moment, so a double click can't skip a line.
func _debounce():
	_debounce_until_msec = Time.get_ticks_msec() + int(DEBOUNCE_TIME * 1000)
