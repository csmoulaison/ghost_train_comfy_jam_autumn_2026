# NOTE: only applies to inside train. in destinations, these are treated with
# ConditionalNodes.

class_name SmallCargoAvatar extends Node2D

@export_multiline var notes: String
@export var cargo_id: ID.SmallCargo = ID.SmallCargo.DEFAULT

@onready var sprite = get_node("Sprite2D")
@onready var interactable: Interactable = get_node("Interactable")

var active: bool = false
var on_first_car: bool = true

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
	var cargo: SmallCargo = ResourceData.small_cargos[cargo_id]
	DialogueState.open_dialogue([], cargo.descriptive_dialogue)

func set_state(is_on_first_car: bool, scene_init: bool):
	on_first_car = is_on_first_car
	if cargo_id != ID.SmallCargo.DEFAULT:
		var cargo: SmallCargo = ResourceData.small_cargos[cargo_id]
		sprite.scale = Vector2(cargo.sprite_scale, cargo.sprite_scale)
		sprite.texture = cargo.default_texture
	if scene_init:
		if check_active(): sprite.modulate.a = 1.0
		else: sprite.modulate.a = 0.0

func check_active() -> bool:
	if cargo_id == ID.SmallCargo.DEFAULT: return false
	if TrainState.small_cargo_on_train[cargo_id] == false: return false
	if !on_first_car: return false
	return true
