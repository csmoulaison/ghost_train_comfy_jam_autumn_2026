class_name PlayerInteractor extends Area2D

## The ghost's reach. Focuses the nearest Interactable inside it, shows the
## prompt above that one, and uses it on the interact key.
##
## Resize the Reach shape in the scene to change the distance.
## Key: Project Settings -> Input Map (interact).

## %s is the interactable's prompt_text. Update the key name here if the Input
## Map changes.
const PROMPT_FORMAT: String = "[Space] %s"

# Top Level in the scene, so it sits above the interactable, not the ghost
@onready var prompt: Node2D = get_node("Prompt")
@onready var prompt_label: Label = get_node("Prompt/Label")

# what the interact key would use right now, or null
var _focused: Interactable = null

func _ready() -> void:
	assert(prompt != null)
	assert(prompt_label != null)
	# only detect the interactable layer
	collision_layer = 0
	collision_mask = 0
	set_collision_mask_value(Interactable.PHYSICS_LAYER, true)
	prompt.visible = false

func _exit_tree() -> void:
	# scene swapped out (see ModeState), what was in reach may be gone later
	_focused = null
	prompt.visible = false

func _process(_delta: float) -> void:
	_focused = _find_nearest_in_reach()

	prompt.visible = _focused != null
	if _focused != null:
		prompt_label.text = PROMPT_FORMAT % _focused.prompt_text
		prompt.global_position = _focused.get_prompt_position()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _focused != null:
		try_interact(_focused)

## public functions

## Uses the interactable if interacting is allowed and it's in reach. Returns
## whether it did.
func try_interact(interactable: Interactable) -> bool:
	if not _can_interact(): return false
	if not can_reach(interactable): return false
	if not interactable.interaction_active: return false

	interactable.interact()
	return true

func can_reach(interactable: Interactable) -> bool:
	return overlaps_area(interactable)

## The interactable at a world position (like a click), in reach or not. Null
## if there isn't one.
func find_interactable_at(point: Vector2) -> Interactable:
	var query: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	query.position = point
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = collision_mask

	for hit in get_world_2d().direct_space_state.intersect_point(query):
		if hit.collider is Interactable:
			return hit.collider
	return null

## private functions

## The one place that decides if interacting is allowed right now.
func _can_interact() -> bool:
	return not ModeState.control_paused()

func _find_nearest_in_reach() -> Interactable:
	if not _can_interact(): return null

	var nearest: Interactable = null
	var nearest_distance: float = INF
	for area in get_overlapping_areas():
		if not (area is Interactable): continue
		if not (area.interaction_active): continue

		var distance: float = global_position.distance_to(area.global_position)
		if distance < nearest_distance:
			nearest = area
			nearest_distance = distance
	return nearest
