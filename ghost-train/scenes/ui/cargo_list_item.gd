extends PanelContainer

@onready var checkmark: TextureRect = get_node("HBoxContainer/CheckBox/Checkmark")
@onready var coins_label: Label = get_node("HBoxContainer/HBoxContainer/CoinAmount")
var checked: bool = false

func _ready():
	assert(checkmark != null)
	assert(coins_label != null)
	#checkmark.gui_input.connect(_on_press)
	
func _process(_dt):
	checkmark.modulate.a = 1.0 if checked else 0.0

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			checked = !checked
			accept_event() 
