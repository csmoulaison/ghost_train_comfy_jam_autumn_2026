class_name Cursor extends Node

enum Type {
	NORMAL,
	CHAT,
	POINT,
	TRAIN,
}

@export var set_normal: Texture2D
@export var set_chat: Texture2D
@export var set_point: Texture2D
@export var set_train: Texture2D

@onready var sprite: Sprite2D = get_node("Sprite")

static var normal
static var chat
static var point
static var train
static var texture: Texture2D
static var offset: Vector2 = Vector2(0,0)
static var opacity: float = 1.0
static var previously_paused = false

func _ready():
	assert(sprite != null)
	normal = set_normal
	chat = set_chat
	point = set_point
	train = set_train
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	change(Type.NORMAL)
	
func _process(dt: float):
	var pause_cursor: bool = ModeState.control_paused() and !DialogueState.is_active() and ModeState.mode != ModeState.GameMode.MAP
	if pause_cursor: 
		change(Type.NORMAL)
		opacity = 0.0
	else: if previously_paused == true: 
		change(Type.NORMAL)
		opacity = 1.0
	previously_paused = pause_cursor
	if sprite.texture != texture: sprite.texture = texture
	sprite.global_position = sprite.get_global_mouse_position()
	sprite.offset = offset
	sprite.modulate.a = lerp(sprite.modulate.a, opacity, 10.0 * dt)
	
static func define_hover(hover_node: Node, hover_cursor: Type):
	hover_node.mouse_entered.connect(change.bind(hover_cursor))
	hover_node.mouse_exited.connect(change.bind(Cursor.Type.NORMAL))

static func change(type: Type):
	if type == Type.NORMAL: set_image(normal, Vector2(4, 4), 1.0)
	else: if type == Type.CHAT: set_image(chat, Vector2(16, 14), 1.0)
	else: if type == Type.POINT: set_image(point, Vector2(10, 4), 1.0)
	else: if type == Type.TRAIN: set_image(train, Vector2(22, 19), 1.0)

static func change_with_opacity(type: Type, set_opacity: float):
	change(type)
	opacity = set_opacity
	
static func set_image(set_texture: Texture2D, set_offset: Vector2, set_opacity: float):
	texture = set_texture
	offset = -set_offset
	opacity = set_opacity
