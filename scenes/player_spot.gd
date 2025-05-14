extends Node
@export var pos: int
@onready var graphic: Sprite2D = $graphic

func _ready() -> void:
	graphic.hide()
