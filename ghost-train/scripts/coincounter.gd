extends CanvasLayer

@onready var anchor: Control = get_node("Anchor")
@onready var coin_amount: Label = get_node("%CoinAmount")
@onready var coin_gain: Label = get_node("%CoinGain")
@onready var anim: AnimationPlayer = get_node("Anchor/AnimationPlayer")

var shown_coins: int = 0      # the number on screen right now
var last_coins: int = 0       # what MoneyState.coins was last frame
var hide_timer: float = 0.0   # seconds left before it fades away

func _ready():
	shown_coins = MoneyState.coins
	last_coins = MoneyState.coins
	coin_amount.text = str(shown_coins)

func _process(dt: float):
	# Money changed
	if MoneyState.coins != last_coins:
		var gain: int = MoneyState.coins - last_coins
		if gain > 0:
			coin_gain.text = "+" + str(gain)
		else:
			coin_gain.text = str(gain)
		anim.stop()
		anim.play("pop")
		hide_timer = 3.0
		last_coins = MoneyState.coins

	# Count up
	if shown_coins < MoneyState.coins:
		shown_coins += 1
	elif shown_coins > MoneyState.coins:
		shown_coins -= 1
	coin_amount.text = str(shown_coins)

	# Timer
	hide_timer -= dt

	# Fade
	var target_opacity: float = 0.0
	if hide_timer > 0.0:
		target_opacity = 1.0
	if ModeState.mode == ModeState.GameMode.MAP:
		target_opacity = 0.0
	anchor.modulate.a = lerp(anchor.modulate.a, target_opacity, dt * 8.0)
		
