@tool extends Sprite2D

var parent: Node = null
var last_person_id: ID.Person = ID.Person.DEFAULT

func _process(_dt) -> void:
	if !Engine.is_editor_hint(): return
	if parent == null:
		parent = get_parent()
	if last_person_id == parent.person_id: return
	last_person_id = parent.person_id
	_update_sprite_in_editor()
	
func _update_sprite_in_editor():
	print("updating sprite in editor")
	var list: Array[Person] = []
	ResourceLoad.initialize_resource_type(list, ID.Person, "people")
	var person: Person = list[last_person_id]
	texture = person.default_texture
	scale = Vector2(person.sprite_scale, person.sprite_scale)
