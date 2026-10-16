extends CanvasLayer
#func _ready():
#func _process(dt):




@onready var achnor: Control = get_node("Anchor")
@onready var coin_amount: Label = get_node("CoinAmount")
@onready var coin_gain: Label = get_node("CointGain")
@onready var anim: AnimationPlayer = get_node("Anchor/AnimationPlayer")

var shown_coins: int = 0      # the number on screen right now
var last_coins: int = 0       # what MoneyState.coins was last frame
var hide_timer: float = 0.0   # seconds left before it fades away
