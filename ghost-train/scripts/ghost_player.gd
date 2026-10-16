class_name GhostPlayer extends Node2D

## The ghost the player floats around as. There are two ways to move:
##   - WASD floats the ghost in that direction
##   - left click floats the ghost to wherever was clicked (prototype only)
## Either way the ghost can go anywhere, but can't leave the screen.
##
## Clicking an Interactable floats over and uses it (see player_interactor.gd).
##
## The keys are set in Project Settings -> Input Map: move_left, move_right,
## move_up, move_down and move_to_click.

## Top speed, in pixels per second.
@export var speed: float = 500.0
## How floaty the ghost feels: the seconds it takes to get up to top speed, and
## to drift to a stop again. 0 is instant (not floaty at all), bigger is
## floatier.
@export var float_time: float = 0.3
## Which way the sprite's art is drawn facing. Untick this if the art gets
## swapped for one that faces right.
@export var art_faces_left: bool = true

@export var idle_texture: Texture2D
@export var walk_texture: Texture2D
@export var idle_blink_texture: Texture2D
@export var walk_blink_texture: Texture2D

var bob_phase: float = 0.0
var bob_damped: float = 0.0
var bob_root: float = 0.0
var in_blink_time: float = 0.0
var next_blink_time: float = 0.0

enum MoveState {
	IDLE,
	MOVING
}

var move_state: MoveState = MoveState.IDLE

@onready var sprite: Sprite2D = get_node("ConditionalNode/Sprite2D")
@onready var interactor: PlayerInteractor = get_node("Interactor")

# how fast, and which way, the ghost is moving right now
var _velocity: Vector2 = Vector2.ZERO

# where the last click told us to go. Only used while _has_click_target is true.
var _click_target: float = 0.0
var _has_click_target: bool = false
# what the last click was on, if anything. Used once the ghost is in reach.
var _click_interactable: Interactable = null

func _ready() -> void:
	assert(sprite != null)
	assert(interactor != null)

func _exit_tree() -> void:
	# scene swapped out (see ModeState), so drop any half finished move
	_cancel_click_move()
	_velocity = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if ModeState.control_paused(): return

	if event.is_action_pressed("move_to_click"):
		var mouse_target: Vector2 = get_global_mouse_position()
		_click_target = mouse_target.x
		_has_click_target = true
		_click_interactable = interactor.find_interactable_at(mouse_target)
		interactor.try_interact(_click_interactable)
		if _click_interactable == null:
			#_has_click_target = false
			pass

func _process(delta: float) -> void:
	# the ghost stays put while someone is talking
	if ModeState.control_paused():
		_cancel_click_move()
		_velocity = Vector2.ZERO
		return

	# the ghost doesn't move at this velocity straight away. Its real velocity
	# drifts toward this one a little each frame, which is what makes it floaty.
	var wanted_velocity: Vector2 = _get_wanted_direction(delta) * speed
	wanted_velocity.y = 0.0

	if float_time <= 0.0:
		_velocity = wanted_velocity
	else:
		_velocity = _velocity.move_toward(wanted_velocity, _get_acceleration() * delta)

	move_state = MoveState.IDLE if _velocity.length() < 0.1 else MoveState.MOVING

	global_position += _velocity * delta
	_keep_on_screen()
	_face_heading()
	_use_clicked_interactable()

func _physics_process(delta):
	var blinking: bool = false
	if in_blink_time > 0.0:
		blinking = true
		in_blink_time -= delta
	next_blink_time -= delta
	if next_blink_time < 0.0:
		next_blink_time = 2.0 + randf() * 4.0
		in_blink_time = 0.1 + randf() * 0.1
	sprite.texture = idle_blink_texture if blinking else idle_texture
	if abs(_velocity.x) > 0.1:
		sprite.texture = walk_blink_texture if blinking else walk_texture
	
	if ModeState.mode == ModeState.GameMode.TRAVEL:
		var bob_root_target: float = 0.0
		if position.x < 930.0:
			bob_root_target = 50.0
		bob_root = lerp(bob_root, bob_root_target, 7.5 * delta)
	else:
		bob_root = 0.0
	
	if bob_damped < abs(_velocity.x): bob_damped = move_toward(bob_damped, abs(_velocity.x), 1200.0 * delta)
	if bob_damped > abs(_velocity.x): bob_damped = move_toward(bob_damped, abs(_velocity.x), 400.0 * delta)
	bob_phase += (2.0 + abs(bob_damped * 0.025)) * delta
	sprite.position.y = sin(bob_phase) * (2.0 + bob_damped * 0.02) + bob_root

## private functions

## The direction the player is asking to go in: from the keys if any are held,
## otherwise toward the clicked spot, otherwise nowhere (ZERO).
func _get_wanted_direction(delta: float) -> Vector2:
	var key_direction: float = Input.get_axis("move_left", "move_right")
	if key_direction != 0.0:
		# the keys always win, so pressing one cancels a click move
		_cancel_click_move()
		return Vector2(key_direction, 0.0)

	if _has_click_target:
		# stop asking to move once we're close enough to drift the rest of the
		# way, so the ghost glides to a stop on the spot instead of overshooting
		var distance: float = global_position.distance_to(Vector2(_click_target, global_position.x))
		if distance <= maxf(_get_stopping_distance(), speed * delta):
			_has_click_target = false
		else:
			return global_position.direction_to(Vector2(_click_target, global_position.x))
	return Vector2.ZERO

## Uses the clicked interactable once it's in reach.
func _use_clicked_interactable() -> void:
	if _click_interactable == null: return

	if interactor.try_interact(_click_interactable):
		# no need to float the rest of the way
		_cancel_click_move()

func _cancel_click_move() -> void:
	_has_click_target = false
	_click_interactable = null

## How quickly the velocity can change, in pixels per second, per second.
func _get_acceleration() -> float:
	return speed / float_time

## How far the ghost would drift before stopping if it let go right now.
func _get_stopping_distance() -> float:
	if float_time <= 0.0:
		return 0.0
	return _velocity.length_squared() / (2.0 * _get_acceleration())

## Pushes the ghost back inside the screen if it has drifted past an edge.
func _keep_on_screen() -> void:
	var screen: Rect2 = _get_screen_rect()
	# half the sprite's size, so the whole ghost stays visible and not just its
	# middle
	var half_size: Vector2 = sprite.get_rect().size * sprite.global_scale * 0.5
	var min_position: Vector2 = screen.position + half_size
	var max_position: Vector2 = screen.end - half_size

	# hitting an edge also stops the ghost in that direction, otherwise it would
	# feel stuck to the edge while its leftover velocity ran out
	if global_position.x < min_position.x or global_position.x > max_position.x:
		_velocity.x = 0.0
	if global_position.y < min_position.y or global_position.y > max_position.y:
		_velocity.y = 0.0

	global_position = global_position.clamp(min_position, max_position)

## Flips the sprite to face the way the ghost is moving. When it isn't moving
## left or right, it keeps facing the way it last was.
func _face_heading() -> void:
	if _velocity.x > 0.0:
		sprite.flip_h = art_faces_left
	elif _velocity.x < 0.0:
		sprite.flip_h = not art_faces_left

## The part of the world that is on screen right now. Without a camera this is
## just the viewport's rect, but going through the canvas transform means it
## keeps working if a Camera2D is added later.
func _get_screen_rect() -> Rect2:
	return get_canvas_transform().affine_inverse() * get_viewport_rect()
