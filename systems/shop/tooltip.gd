extends CanvasLayer
@onready var panel_container: PanelContainer = $PanelContainer
@onready var title: Label = $PanelContainer/VBoxContainer/Title
@onready var sub: Label = $PanelContainer/VBoxContainer/Sub

var is_left = true

func _ready():
	process_mode = PROCESS_MODE_ALWAYS

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	var panel_size = panel_container.get_combined_minimum_size()
	
	if mouse_pos.x > viewport_size.x / 2 and not visible:
		# Anchor left side
		panel_container.position.x = 60  # 20px from left
	if mouse_pos.x < viewport_size.x / 2 and not visible:
		# Anchor right side
		panel_container.position.x = viewport_size.x - panel_size.x - 60


func set_text(title: String, subtitle: String) -> void:
	if title:
		self.title.text = title
		self.sub.text = subtitle
		await get_tree().process_frame  # Ensures layout updates
		show()

func hide_tooltip() -> void:
	hide()
