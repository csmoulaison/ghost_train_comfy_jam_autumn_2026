extends Node2D

@export var locomotive_wheel_frames: Array[Texture2D] = []

@onready var interactable: Interactable = get_node("Locomotive/Interactable")
@onready var locomotive_wheel_sprite: Sprite2D = get_node("LocomotiveWheelSprite")
@onready var small_wheel_sprites: Array[Node] = find_children("Wheel*")

var locomotive_t: float = 0.0
var locomotive_wheel_frame_count: int = 0
var previous_x: float = 0.0

func _ready():
	assert(interactable != null)
	interactable.interacted.connect(_on_interacted)
	interactable.input_event.connect(_on_input_event)
	locomotive_wheel_frame_count = locomotive_wheel_frames.size()
	previous_x = position.x
	
func _physics_process(_dt: float):
	locomotive_t += ((previous_x - position.x) * 0.01) / scale.x
	previous_x = position.x
	locomotive_wheel_sprite.texture = locomotive_wheel_frames[int(locomotive_t) % locomotive_wheel_frame_count]
	for wheel in small_wheel_sprites:
		wheel.rotation = -locomotive_t
	
func _process(dt: float):
	match ModeState.mode:
		ModeState.GameMode.DESTINATION:
			interactable.interaction_active = false
			interactable.prompt_text = "Depart"
		ModeState.GameMode.TRAVEL:
			interactable.interaction_active = true
			interactable.prompt_text = "Arrive"

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if !ModeState.control_paused() and ModeState.GameMode.DESTINATION:
			ModeState.enter_map_mode(false)

func _on_interacted():
	match ModeState.mode:
		ModeState.GameMode.DESTINATION:
			pass
			#ModeState.enter_map_mode(false)
		ModeState.GameMode.TRAVEL:
			ModeState.exit_travel_mode(TrainState.next_location)
		_:
			assert(false, "Interacted with train avatar, not in destination or travel mode?")
