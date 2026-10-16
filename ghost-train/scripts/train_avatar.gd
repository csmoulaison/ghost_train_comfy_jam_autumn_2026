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
	Cursor.define_hover(interactable, Cursor.Type.TRAIN)
	interactable.interacted.connect(_on_interacted)
	interactable.input_event.connect(_on_input_event)
	locomotive_wheel_frame_count = locomotive_wheel_frames.size()
	for wheel in small_wheel_sprites:
		wheel.rotation = randf() * 1000.0
	previous_x = position.x
	interactable.interaction_active = false
	
func _physics_process(dt: float):
	#if GameState.flags[ID.Flag.ON_END_TRAIN]: 
	interactable.interaction_active = false
	
	var delta: float = -(((previous_x - position.x) * 0.01) / scale.x)
	if ModeState.mode == ModeState.GameMode.TRAVEL: delta = 20.0 * dt
	
	locomotive_t += delta
	previous_x = position.x
	locomotive_wheel_sprite.texture = locomotive_wheel_frames[int(locomotive_t) % locomotive_wheel_frame_count]
	for wheel in small_wheel_sprites:
		wheel.rotation = locomotive_t

func _process(_dt: float):
	match ModeState.mode:
		ModeState.GameMode.DESTINATION:
			interactable.interaction_active = false
			interactable.prompt_text = ""
		ModeState.GameMode.TRAVEL:
			interactable.interaction_active = true
			interactable.prompt_text = ""

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if !ModeState.control_paused() and ModeState.mode == ModeState.GameMode.DESTINATION:
			ModeState.enter_map_mode(false)
	if ModeState.mode != ModeState.GameMode.DESTINATION:
		Cursor.change(Cursor.Type.NORMAL)

func _on_interacted():
	if GameState.flags[ID.Flag.ON_END_TRAIN]: return
	match ModeState.mode:
		ModeState.GameMode.DESTINATION:
			return
		ModeState.GameMode.TRAVEL:
			ModeState.exit_travel_mode(TrainState.next_location)
		_:
			assert(false, "Interacted with train avatar, not in destination or travel mode?")
