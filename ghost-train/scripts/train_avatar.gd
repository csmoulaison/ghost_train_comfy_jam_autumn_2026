extends Node2D

@export var locomotive_wheel_frames: Array[Texture2D] = []

@onready var depart_interactable: Interactable = get_node("Locomotive/DepartInteractable")
@onready var arrive_interactable: Interactable = get_node("Locomotive/ArriveInteractable")
@onready var locomotive_wheel_sprite: Sprite2D = get_node("LocomotiveWheelSprite")
@onready var small_wheel_sprites: Array[Node] = find_children("Wheel*")

var locomotive_t: float = 0.0
var locomotive_wheel_frame_count: int = 0
var previous_x: float = 0.0

func _ready():
	assert(depart_interactable != null)
	Cursor.define_hover(depart_interactable, Cursor.Type.TRAIN)
	depart_interactable.input_event.connect(_on_depart_input_event)
	assert(arrive_interactable != null)
	Cursor.define_hover(arrive_interactable, Cursor.Type.TRAIN)
	arrive_interactable.interacted.connect(_on_arrive_interacted)
	
	locomotive_wheel_frame_count = locomotive_wheel_frames.size()
	for wheel in small_wheel_sprites:
		wheel.rotation = randf() * 1000.0
	previous_x = position.x
	
func _physics_process(dt: float):
	var delta: float = -(((previous_x - position.x) * 0.01) / scale.x)
	if ModeState.mode == ModeState.GameMode.TRAVEL: delta = 20.0 * dt
	
	locomotive_t += delta
	previous_x = position.x
	locomotive_wheel_sprite.texture = locomotive_wheel_frames[int(locomotive_t) % locomotive_wheel_frame_count]
	for wheel in small_wheel_sprites:
		wheel.rotation = locomotive_t

func _process(_dt: float):
	depart_interactable.interaction_active = false
	match ModeState.mode:
		ModeState.GameMode.DESTINATION:
			depart_interactable.visible = true
			arrive_interactable.visible = false
			arrive_interactable.interaction_active = false
		ModeState.GameMode.TRAVEL:
			depart_interactable.visible = false
			arrive_interactable.visible = true
			arrive_interactable.interaction_active = true
			if GameState.flags[ID.Flag.ON_END_TRAIN]: 
				arrive_interactable.visible = false
				arrive_interactable.interaction_active = false

func _on_depart_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if !ModeState.control_paused():
			ModeState.enter_map_mode(false, false)
	# Switch cursor back if we just changed modes
	if ModeState.mode != ModeState.GameMode.DESTINATION:
		Cursor.change(Cursor.Type.NORMAL)

func _on_arrive_interacted():
	if ModeState.mode == ModeState.GameMode.TRAVEL and !GameState.flags[ID.Flag.ON_END_TRAIN]:
		ModeState.exit_travel_mode(TrainState.next_location)
