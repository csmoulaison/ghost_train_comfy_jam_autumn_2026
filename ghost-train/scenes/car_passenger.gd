extends Node2D

@export var front: Sprite2D
@export var booth: Sprite2D
@export var collision: CollisionShape2D

var target_opacity = 1.0

func _physics_process(delta):
	front.modulate.a = lerp(front.modulate.a, target_opacity, delta * 8.0)
