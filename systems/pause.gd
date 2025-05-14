extends Control
@onready var pause_menu: Control = $"."
@onready var restart: Button = $Restart

var paused = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if paused:
		pause_menu.visible = true
	else:
		pause_menu.visible = false
	if Input.is_action_just_pressed("Pause"):
		if paused:
			get_tree().paused = false
			paused = false
		else:
			get_tree().paused = true
			paused = true
			
