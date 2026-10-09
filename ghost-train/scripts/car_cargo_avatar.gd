extends Sprite2D

var cargo_car_index: int = -1

func _process(dt: float):
	modulate.a = lerp(modulate.a, get_target_opacity(), dt * 8.0)

func set_state(car_index: int, scene_init: bool):
	cargo_car_index = car_index
	texture = ResourceData.cargos[TrainState.cargo_slots[cargo_car_index]].car_texture
	if scene_init:
		modulate.a = get_target_opacity()

func get_target_opacity() -> float:
	var cargo: ID.Cargo = TrainState.cargo_slots[cargo_car_index]
	return 1.0 if cargo != ID.Cargo.DEFAULT else 0.0
