class_name Interactable extends Area2D

## Makes its parent something the player can interact with. To use:
##   1. add this as a child of the thing (a person, cargo, a door)
##   2. give it a CollisionShape2D about the size of the thing
##   3. connect: interactable.interacted.connect(_on_interacted)
##
## What interacting does is up to whoever listens to the signal.

signal interacted

## Shown in the prompt, like "Talk" or "Load".
@export var prompt_text: String = "Interact"
## Where the prompt sits relative to this node. Up is negative.
@export var prompt_offset: Vector2 = Vector2(0.0, -80.0)

## Only interactables use this 2D physics layer, so the player's reach finds
## nothing else. Named in Project Settings -> Layer Names.
const PHYSICS_LAYER: int = 2

func _ready() -> void:
	# set in code so a new interactable can't forget to
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(PHYSICS_LAYER, true)

func interact() -> void:
	interacted.emit()

## In world coordinates.
func get_prompt_position() -> Vector2:
	return to_global(prompt_offset)
