extends Node2D
@onready var head: Sprite2D = $head
const WIZARD_MAD = preload("res://systems/shop/wizard mad.png")
const WIZARD_HEAD = preload("res://systems/shop/wizard head.png")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	head.texture = WIZARD_MAD if GameState.shopkeeper_mad else WIZARD_HEAD
