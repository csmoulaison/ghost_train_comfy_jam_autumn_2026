class_name PersonAvatar extends Node2D

@export_multiline var notes: String
@export var person_id: ID.Person = ID.Person.DEFAULT
@export var conditions: Array[StateCondition] = []
# TODO(now): make this prevent normal interaction and instead just be immediate
# click which activates new found_jackokid_dialogue field in person resource.
@export var is_hiding_jackokid: bool = false
@export var dressing: bool = false
@export var is_grimm_at_end: bool = false

@onready var sprite = get_node("Sprite2D")
@onready var interactable: Interactable = get_node("Interactable")

var active: bool = false
var on_train: bool = false
var location: ID.Location = ID.Location.DEFAULT

func _ready():
	assert(sprite != null)
	assert(interactable != null)
	interactable.interacted.connect(_on_interacted)
	interactable.input_event.connect(_on_input_event)
	interactable.mouse_entered.connect(_on_mouse_entered)
	interactable.mouse_exited.connect(Cursor.change.bind(Cursor.Type.NORMAL))

func _process(dt: float):
	active = check_active()
	var target_opacity: float = 0.0
	set_interactable(false)
	if active:
		target_opacity = 1.0
		if on_train and ModeState.mode == ModeState.GameMode.TRAVEL or !on_train and ModeState.mode == ModeState.GameMode.DESTINATION:
			set_interactable(true)
	if (is_hiding_jackokid and ModeState.mode == ModeState.GameMode.DESTINATION) or dressing:
		set_interactable(false)
	sprite.modulate.a = lerp(sprite.modulate.a, target_opacity, dt * 8.0)

func set_interactable(isit: bool):
	interactable.interaction_active = isit
	interactable.input_pickable = isit

func _on_mouse_entered():
	if interactable.interaction_active:
		Cursor.change(Cursor.Type.CHAT)

func _on_interacted():
	var person: Person = ResourceData.people[person_id]
	DialogueState.open_dialogue(person.conditional_interact_dialogue, person.default_interact_dialogue)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if !is_grimm_at_end:
			if !is_hiding_jackokid: return
			if GameState.people_locations[person_id] != TrainState.current_location: return
		var person: Person = ResourceData.people[person_id]
		DialogueState.open_dialogue([], person.found_jackokid_dialogue)

func set_state(id: ID.Person, set_on_train: bool, set_location: ID.Location, scene_init: bool):
	person_id = id
	on_train = set_on_train
	location = set_location
	if person_id != ID.Person.DEFAULT:
		var person: Person = ResourceData.people[person_id]
		sprite.scale = Vector2(person.sprite_scale, person.sprite_scale)
		sprite.texture = person.default_texture
	if scene_init:
		if check_active(): sprite.modulate.a = 1.0
		else: sprite.modulate.a = 0.0

func check_active() -> bool:
	if is_grimm_at_end and GameState.flags[ID.Flag.ON_END_TRAIN]: return true
	if person_id == ID.Person.DEFAULT: return false
	if on_train and !TrainState.person_on_train(person_id): return false
	else: if !on_train and GameState.people_locations[person_id] != TrainState.current_location: return false
	if !StateCondition.check_list(conditions): return false
	return true
