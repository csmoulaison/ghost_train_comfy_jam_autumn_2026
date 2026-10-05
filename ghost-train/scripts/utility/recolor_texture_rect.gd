@tool
class_name RecolorTextureRect
extends TextureRect

## A TextureRect that can be repainted in any colour, keeping the image's shape
## (its transparency). Modulate can only make an image darker, so it can't turn
## a black icon white. This can.

const RECOLOR_SHADER: Shader = preload("res://resources/shaders/recolor.gdshader")

## The colour to paint the image.
@export var recolor: Color = Color.WHITE:
	set(value):
		recolor = value
		_refresh()

## 0 leaves the image as it is, 1 replaces its colours completely.
@export_range(0.0, 1.0) var recolor_amount: float = 1.0:
	set(value):
		recolor_amount = value
		_refresh()

func _ready() -> void:
	# each node gets its own material, so they can all be different colours
	var shader_material := ShaderMaterial.new()
	shader_material.shader = RECOLOR_SHADER
	material = shader_material
	_refresh()

func _refresh() -> void:
	var shader_material := material as ShaderMaterial
	if shader_material == null or shader_material.shader != RECOLOR_SHADER: return

	shader_material.set_shader_parameter("recolor", recolor)
	shader_material.set_shader_parameter("amount", recolor_amount)
