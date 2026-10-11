extends Node2D

@export var conditions: Array[StateCondition] = []

func _process(dt: float):
	var target_opacity: float = 0.0
	if StateCondition.check_list(conditions):
		target_opacity = 1.0
	modulate.a = lerp(modulate.a, target_opacity, dt * 8.0)

func scene_load():
	if StateCondition.check_list(conditions): modulate.a = 1.0
	else: modulate.a = 0.0
