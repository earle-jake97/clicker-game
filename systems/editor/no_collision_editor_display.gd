@tool
extends Node2D
const LABEL = "NC"

var font = ThemeDB.fallback_font

@export var tilemap: TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		set_process(true)
	else:
		set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw():
	if not Engine.is_editor_hint():
		return
	for cell in tilemap.get_used_cells():
		var tile_data = tilemap.get_cell_tile_data(cell)
		if tile_data and tile_data.get_custom_data("no_collision") == true:
			var world_pos = tilemap.map_to_local(cell)
			draw_string(font, world_pos, LABEL, HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color.WHITE)
