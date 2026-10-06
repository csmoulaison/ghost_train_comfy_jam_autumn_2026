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

@onready var animation_player: AnimationPlayer = %AnimationPlayer

## Top speed, in pixels per second.
@export var speed: float = 400.0
## How floaty the ghost feels: the seconds it takes to get up to top speed, and
## to drift to a stop again. 0 is instant (not floaty at all), bigger is
## floatier.
@export var float_time: float = 0.4
## Which way the sprite's art is drawn facing. Untick this if the art gets
## swapped for one that faces right.
@export var art_faces_left: bool = true

enum MoveState {
	IDLE,
	MOVING
}

var move_state: MoveState = MoveState.IDLE

@onready var sprite: Sprite2D = get_node("Sprite2D")
@onready var interactor: PlayerInteractor = get_node("Interactor")

# how fast, and which way, the ghost is moving right now
var _velocity: Vector2 = Vector2.ZERO

# where the last click told us to go. Only used while _has_click_target is true.
var _click_target: Vector2 = Vector2.ZERO
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
	if DialogueState.is_active(): return

	if event.is_action_pressed("move_to_click"):
		_click_target = get_global_mouse_position()
		_has_click_target = true
		_click_interactable = interactor.find_interactable_at(_click_target)

func _process(delta: float) -> void:
	# the ghost stays put while someone is talking
	if DialogueState.is_active():
		_cancel_click_move()
		_velocity = Vector2.ZERO
		return

	# the ghost doesn't move at this velocity straight away. Its real velocity
	# drifts toward this one a little each frame, which is what makes it floaty.
	var wanted_velocity: Vector2 = _get_wanted_direction(delta) * speed

	if float_time <= 0.0:
		_velocity = wanted_velocity
	else:
		_velocity = _velocity.move_toward(wanted_velocity, _get_acceleration() * delta)

	move_state = MoveState.IDLE if _velocity.length() < 0.1 else MoveState.MOVING

	match move_state:
		MoveState.IDLE:
			animation_player.play("idle")
		MoveState.MOVING:
			animation_player.play("idle") # <- can change later...

	global_position += _velocity * delta
	_keep_on_screen()
	_face_heading()
	_use_clicked_interactable()

## private functions

## The direction the player is asking to go in: from the keys if any are held,
## otherwise toward the clicked spot, otherwise nowhere (ZERO).
func _get_wanted_direction(delta: float) -> Vector2:
	var key_direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if key_direction != Vector2.ZERO:
		# the keys always win, so pressing one cancels a click move
		_cancel_click_move()
		return key_direction

	if _has_click_target:
		# stop asking to move once we're close enough to drift the rest of the
		# way, so the ghost glides to a stop on the spot instead of overshooting
		var distance: float = global_position.distance_to(_click_target)
		if distance <= maxf(_get_stopping_distance(), speed * delta):
			_has_click_target = false
		else:
			return global_position.direction_to(_click_target)

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
