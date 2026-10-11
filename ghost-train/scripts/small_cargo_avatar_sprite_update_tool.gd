@tool extends Sprite2D

var parent: Node = null
var last_cargo_id: ID.SmallCargo = ID.SmallCargo.DEFAULT

func _process(_dt) -> void:
	if !Engine.is_editor_hint(): return
	if parent == null:
		parent = get_parent()
	if last_cargo_id == parent.cargo_id: return
	last_cargo_id = parent.cargo_id
	_update_sprite_in_editor()
	
func _update_sprite_in_editor():
	print("updating sprite in editor")
	var list: Array[SmallCargo] = []
	ResourceLoad.initialize_resource_type(list, ID.SmallCargo, "small_cargos")
	var cargo: SmallCargo = list[last_cargo_id]
	texture = cargo.default_texture
	scale = Vector2(cargo.sprite_scale, cargo.sprite_scale)
