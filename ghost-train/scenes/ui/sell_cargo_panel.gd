class_name CargoUI extends CenterContainer

@export var cargo_nodes: Array[Node]
@export var sell_button: TextureButton
@export var sell_button_label: Label
@export var cancel_button: TextureButton
@export var on_sell_dialogue: DialogueLine
@export var on_not_sell_dialogue: DialogueLine
@export var sell_sounds: Array[AudioStream]

var sell_total: int = 0
var opacity: float = 0.0

func _ready():
	sell_button.pressed.connect(_on_sell)
	cancel_button.pressed.connect(_on_cancel)
	visible = false
	EventBus.event_signal.connect(_on_event)

func _process(_dt):
	if !visible: return
	sell_total = 0
	for id in cargo_nodes.size():
		var node = cargo_nodes[id]
		if node.checked and node.visible: 
			sell_total += ResourceData.cargos[id + 1].revenue
	sell_button_label.text = "Sell selected +" + str(sell_total)
	
func _physics_process(delta: float):
	modulate.a = lerp(modulate.a, opacity, delta * 10.0)
	if ModeState.mode != ModeState.GameMode.SELL_CARGO and modulate.a < 0.05:
		visible = false

func _on_event(event: ID.Event, _arg: int):
	if event == ID.Event.OPEN_CARGO_SELL:
		ModeState.enter_cargo_mode()

func _on_sell():
	Cursor.change(Cursor.Type.NORMAL)
	close()
	if sell_total > 0:
		for id in cargo_nodes.size():
			var node = cargo_nodes[id]
			if node.checked: 
				TrainState.sell_cargo(id + 1)
		#MoneyState.add_coins(sell_total)
		DialogueState.open_dialogue([], on_sell_dialogue)
		AudioState.play(sell_sounds[randi_range(0, sell_sounds.size() - 1)], AudioState.dialogue_sound_player)
	else: DialogueState.open_dialogue([], on_not_sell_dialogue)
	
func _on_cancel():
	Cursor.change(Cursor.Type.NORMAL)
	close()
	DialogueState.open_dialogue([], on_not_sell_dialogue)

func open():
	visible = true
	opacity = 1.0
	for id in cargo_nodes.size():
		var node = cargo_nodes[id]
		var cargo: Cargo = ResourceData.cargos[id + 1]
		if !TrainState.cargo_on_train(id + 1): 
			node.visible = false
		else: 
			node.visible = true
			node.checked = false
			node.coins_label.text = str(cargo.revenue)

func close():
	opacity = 0.0
	ModeState.switch_mode(ModeState.GameMode.DESTINATION)
