extends Node

@onready var camera: Camera2D = get_tree().current_scene.get_node("Camera")

var groups: Array[Node]
var copies: Array[Node]
var copy_is_leftmost: Array[bool]
var scroll_speed: float = 1500.0
var center_camera_x: float = 0.0
var train_ghost_player: Node2D = null
var threshold_offset: float = 0.0
var active: bool = false

func _ready():
	assert(camera != null)
	center_camera_x = camera.position.x

func _physics_process(dt: float):
	if active:
		var xdelta: float = scroll_speed * dt
		#var original_x: float = camera.position.x
		camera.position.x = lerp(camera.position.x, train_ghost_player.position.x, 10.0 * dt)
		#var cam_xdelta: float = camera.position.x - original_x
		threshold_offset = camera.position.x - center_camera_x # because camera center isn't at far left
		#threshold_offset = camera.position.x
		#xdelta += cam_xdelta
		move(xdelta)
	else:
		camera.position.x = center_camera_x
			
func move(xdelta: float):
	for index in groups.size():
		var group: ParallaxGroup = groups[index]
		var copy: ParallaxGroup = copies[index]
		group.global_position.x -= xdelta * group.parallax_scroll_ratio
		if copy_is_leftmost[index] and copy.global_position.x < -copy.pixel_repeat_width + threshold_offset:
			copy_is_leftmost[index] = false
			copy.position.x = group.pixel_repeat_width
		else: if !copy_is_leftmost[index] and group.global_position.x < -group.pixel_repeat_width + threshold_offset:
			copy_is_leftmost[index] = true
			group.position.x += group.pixel_repeat_width
			copy.position.x = -group.pixel_repeat_width
		# cases for moving left
		else: if copy_is_leftmost[index] and group.global_position.x > group.pixel_repeat_width + threshold_offset:
			copy_is_leftmost[index] = false
			copy.position.x = group.pixel_repeat_width
		else: if !copy_is_leftmost[index] and copy.global_position.x > copy.pixel_repeat_width + threshold_offset:
			copy_is_leftmost[index] = true
			group.position.x -= group.pixel_repeat_width
			copy.position.x = -group.pixel_repeat_width

func begin_parallax():
	groups.clear()
	copies.clear()
	copy_is_leftmost.clear()
	assert(ModeState.loaded_scene_instance != null)
	groups = ModeState.loaded_scene_instance.find_children("ParallaxGroup*")
	train_ghost_player = ModeState.travel_scene.get_node("GhostPlayer")
	camera.position.x = train_ghost_player.position.x
	camera.reset_smoothing()
	assert(train_ghost_player != null)
	var size: int = groups.size()
	copies.resize(size)
	copy_is_leftmost.resize(size)
	for index in size:
		var group: ParallaxGroup = groups[index]
		group.global_position = Vector2(0.0, group.global_position.y)
		copies[index] = group.duplicate()
		group.add_child(copies[index])
		copies[index].position = Vector2(group.pixel_repeat_width, 0.0)
		copy_is_leftmost[index] = false
	active = true

func end_parallax():
	groups.clear()
	copies.clear()
	copy_is_leftmost.clear()
	train_ghost_player = null
	active = false
	camera.position.x = center_camera_x
	camera.reset_smoothing()
