extends Node

var groups: Array[Node]
var copies: Array[Node]
var copy_is_leftmost: Array[bool]
var scroll_speed: float = 1000.0

func _process(dt: float):
	for index in groups.size():
		var group: ParallaxGroup = groups[index]
		var copy: ParallaxGroup = copies[index]
		group.global_position.x -= scroll_speed * group.parallax_scroll_ratio * dt
		# copy.global_position.x -= scroll_speed * group.parallax_scroll_ratio * dt
		if copy_is_leftmost[index] and copy.global_position.x < -copy.pixel_repeat_width:
			print("copy leapfrogging")
			copy_is_leftmost[index] = false
			copy.position.x = group.pixel_repeat_width
		else: if !copy_is_leftmost[index] and group.global_position.x < -group.pixel_repeat_width:
			print("group leapfrogging")
			copy_is_leftmost[index] = true
			group.position.x += group.pixel_repeat_width
			copy.position.x = -group.pixel_repeat_width

func begin_parallax():
	groups.clear()
	copies.clear()
	copy_is_leftmost.clear()
	groups = ModeState.loaded_scene_instance.find_children("ParallaxGroup*")
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

func end_parallax():
	groups.clear()
	copies.clear()
	copy_is_leftmost.clear()
