class_name PersonAvatar extends Node2D

@export var person_id: ID.Person = ID.Person.DEFAULT

@onready var sprite = get_node("Sprite2D")
@onready var interactable: Interactable = get_node("Interactable")

var active: bool = false
var on_train: bool = false
var location: ID.Location = ID.Location.DEFAULT

func _ready():
	assert(sprite != null)
	assert(interactable != null)
	interactable.interacted.connect(_on_interacted)
	
func _process(dt: float):
	active = check_active()
	var target_opacity: float = 0.0
	interactable.interaction_active = false
	if active:
		target_opacity = 1.0
		interactable.interaction_active = true
	sprite.modulate.a = lerp(sprite.modulate.a, target_opacity, dt * 8.0)
	
func _on_interacted():
	var person: Person = ResourceData.people[person_id]
	DialogueState.open_dialogue(person.conditional_interact_dialogue, person.default_interact_dialogue)

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
	if person_id == ID.Person.DEFAULT: return false
	var result = true
	if on_train and !TrainState.person_on_train(person_id): result = false
	else: if !on_train and GameState.people_locations[person_id] != TrainState.current_location: result = false
	return result
