@tool
class_name DialoguePanel
extends Control

## A dialogue box. Goes on a Panel or a PanelContainer, which draws as normal
## by default. Optional effects from
## dialogue_border.gdshader can be switched on separately: wavy_border swaps
## the flat background for the animated one, background_pattern tiles an image
## across the box, and edge_softness fades out its edge.
##
## Also plays the box's enter and exit animations. The dialogue overlay calls
## play_enter() and play_exit().

enum Transition { FADE, SCALE, POP, SLIDE }

## The shader needs this much empty room around the box for its glow.
const GLOW_PADDING: float = 40.0

const FADE_TIME: float = 0.2
const SCALE_TIME: float = 0.25
const SCALE_FROM: float = 0.85
const POP_TIME: float = 0.55
const POP_FROM: float = 0.75
## How big the box swells before it pops away.
const POP_SWELL: float = 1.06
const SLIDE_TIME: float = 0.35
## Extra distance for the slide, so the name sticking out of the top of the box
## ends up off screen too.
const SLIDE_MARGIN: float = 64.0

@export var wavy_border: bool = false:
	set(value):
		wavy_border = value
		_refresh()

@export var background_pattern: bool = false:
	set(value):
		background_pattern = value
		_refresh()

## Width in pixels of the fade at the edge of the box. 0 keeps the edge crisp.
@export_range(0.0, 24.0, 0.5) var edge_softness: float = 0.0:
	set(value):
		edge_softness = value
		_refresh()

## Material using dialogue_border.gdshader, shared by all the effects. Colours,
## glow and wobble are tuned on the material itself.
@export var effects_material: ShaderMaterial:
	set(value):
		effects_material = value
		_refresh()

@export_group("Wavy Border")

## How far the wavy box sticks out past the panel on the left, top and right,
## so the text keeps clear of the ribbons. The bottom stays flush so the glow
## stays on screen.
@export var edge_overhang: float = 16.0:
	set(value):
		edge_overhang = value
		_refresh()

## How closely the ribbon lines bunch together. 0 lets each one wander on its
## own, 1 pulls them all onto the edge of the box.
@export_range(0.0, 1.0) var line_tightness: float = 0.5:
	set(value):
		line_tightness = value
		_refresh()

@export_group("Background Pattern")

## Image tiled across the inside of the box.
@export var pattern_texture: Texture2D:
	set(value):
		pattern_texture = value
		_refresh()

## How strongly the pattern shows over the background.
@export_range(0.0, 1.0) var pattern_opacity: float = 0.1:
	set(value):
		pattern_opacity = value
		_refresh()

## Size of each tile, as a multiple of the image's own size.
@export_range(0.1, 4.0) var pattern_scale: float = 1.0:
	set(value):
		pattern_scale = value
		_refresh()

@export_group("Transitions")

## How the box arrives when dialogue starts.
@export var enter_transition: Transition = Transition.FADE

## How the box leaves when dialogue ends.
@export var exit_transition: Transition = Transition.FADE

var _transition_tween: Tween

## The shader draws on this. It's bigger than the panel (the glow needs room),
## so it can't be the panel itself. Created in code so the scene stays one node.
var _effects_rect: ColorRect

func _ready() -> void:
	_effects_rect = ColorRect.new()
	_effects_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# A PanelContainer resizes every Control child to fit inside it. Putting
	# the rect under a Node2D keeps it out of the container's reach.
	var holder := Node2D.new()
	holder.add_child(_effects_rect)
	# internal + front: drawn over the panel's background, under its children
	add_child(holder, false, Node.INTERNAL_MODE_FRONT)
	resized.connect(_refresh)
	_refresh()

func _notification(what: int) -> void:
	# the plain look is copied from the panel's stylebox, so follow its changes
	if what == NOTIFICATION_THEME_CHANGED:
		_refresh()

## Puts the box in its hidden state, with no animation.
func hide_instantly() -> void:
	if _transition_tween:
		_transition_tween.kill()
	modulate.a = 0.0
	_reset_pose()

## Returns the tween, so the caller can add a callback for when it's done.
func play_enter() -> Tween:
	var tween: Tween = _start_transition()
	_reset_pose()

	match enter_transition:
		Transition.FADE:
			tween.tween_property(self, "modulate:a", 1.0, FADE_TIME)
		Transition.SCALE:
			offset_transform_scale = Vector2.ONE * SCALE_FROM
			tween.tween_property(self, "offset_transform_scale", Vector2.ONE, SCALE_TIME) \
					.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(self, "modulate:a", 1.0, SCALE_TIME)
		Transition.POP:
			# elastic overshoots and settles, which is what gives the jiggle
			offset_transform_scale = Vector2.ONE * POP_FROM
			tween.tween_property(self, "offset_transform_scale", Vector2.ONE, POP_TIME) \
					.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(self, "modulate:a", 1.0, FADE_TIME * 0.5)
		Transition.SLIDE:
			modulate.a = 1.0
			offset_transform_position = Vector2(0.0, _get_slide_distance())
			tween.tween_property(self, "offset_transform_position", Vector2.ZERO, SLIDE_TIME) \
					.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	return tween

## Returns the tween, so the caller can add a callback for when it's done.
func play_exit() -> Tween:
	var tween: Tween = _start_transition()

	match exit_transition:
		Transition.FADE:
			tween.tween_property(self, "modulate:a", 0.0, FADE_TIME)
		Transition.SCALE:
			tween.tween_property(self, "offset_transform_scale", Vector2.ONE * SCALE_FROM, FADE_TIME) \
					.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			tween.parallel().tween_property(self, "modulate:a", 0.0, FADE_TIME)
		Transition.POP:
			tween.tween_property(self, "offset_transform_scale", Vector2.ONE * POP_SWELL, FADE_TIME * 0.4) \
					.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "offset_transform_scale", Vector2.ONE * POP_FROM, FADE_TIME) \
					.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			tween.parallel().tween_property(self, "modulate:a", 0.0, FADE_TIME)
		Transition.SLIDE:
			tween.tween_property(self, "offset_transform_position", Vector2(0.0, _get_slide_distance()), SLIDE_TIME) \
					.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	return tween

func _start_transition() -> Tween:
	if _transition_tween:
		_transition_tween.kill()
	# The offset transform moves and scales the box on screen without touching
	# its layout, so the anchors never fight the animation.
	offset_transform_enabled = true
	offset_transform_pivot_ratio = Vector2(0.5, 0.5)
	_transition_tween = create_tween()
	return _transition_tween

func _reset_pose() -> void:
	offset_transform_scale = Vector2.ONE
	offset_transform_position = Vector2.ZERO

## How far down the box has to move to be completely off the bottom of the
## screen.
func _get_slide_distance() -> float:
	return get_viewport_rect().size.y - global_position.y + SLIDE_MARGIN

func _refresh() -> void:
	if _effects_rect == null: return

	var has_material: bool = effects_material != null
	var show_border: bool = wavy_border and has_material
	var show_pattern: bool = background_pattern and pattern_texture != null and has_material
	var show_soft_edge: bool = edge_softness > 0.0 and has_material
	_effects_rect.visible = show_border or show_pattern or show_soft_edge
	# With any effect on, the shader draws the whole background, so hide the
	# panel's own. self_modulate only affects the panel itself, not its children.
	self_modulate.a = 0.0 if _effects_rect.visible else 1.0
	if not _effects_rect.visible: return

	# Without the border, the box has to line up with the plain panel.
	var overhang: float = edge_overhang if show_border else 0.0
	var grow: float = GLOW_PADDING + overhang
	_effects_rect.position = Vector2(-grow, -grow)
	_effects_rect.size = size + Vector2(grow * 2.0, grow + GLOW_PADDING)

	_effects_rect.material = effects_material
	effects_material.set_shader_parameter("rect_size", _effects_rect.size)
	effects_material.set_shader_parameter("padding", GLOW_PADDING)
	effects_material.set_shader_parameter("border_enabled", show_border)
	effects_material.set_shader_parameter("edge_softness", edge_softness)
	effects_material.set_shader_parameter("ribbon_tightness", line_tightness)
	effects_material.set_shader_parameter("pattern_texture", pattern_texture)
	effects_material.set_shader_parameter("pattern_opacity", pattern_opacity if show_pattern else 0.0)
	effects_material.set_shader_parameter("pattern_scale", pattern_scale)

	# Without the border, the shader copies the colour and corner radius of the
	# panel's stylebox. Borders and shadows on the stylebox aren't copied.
	var plain_style := get_theme_stylebox("panel") as StyleBoxFlat
	if plain_style:
		effects_material.set_shader_parameter("plain_fill_color", plain_style.bg_color)
		effects_material.set_shader_parameter("plain_corner_radius", plain_style.corner_radius_top_left)
