extends Node2D
@export var noise_texture : NoiseTexture2D
@export var tree_noise_texture : NoiseTexture2D
var width : int = 200
var height : int =  200
@onready var ground_region: NavigationRegion2D = $"../Ground Region"

var noise : Noise
var tree_noise : Noise

var water_tile_atlas = Vector2i(0,1)
var changeset : Dictionary

var sand_layer = 4
var water_layer = 5
var dirt_layer = 2
var grass_layer = 1

@onready var tilemap: TileMapLayer = $"../tilemap"

var random_grass_atlas_arr = [Vector2i(9,2)]

func _ready():
	noise = noise_texture.noise
	noise.seed =randi()
	generate_world()
	bake_navmesh()

func _process(delta: float) -> void:
	
	if BetterTerrain.is_terrain_changeset_ready(changeset):
		BetterTerrain.apply_terrain_changeset(changeset)
		changeset = {}

func bake_navmesh():
	await get_tree().physics_frame   # ensures colliders exist
	await get_tree().physics_frame   # ensures colliders exist
	
	print("baking")
	ground_region.bake_navigation_polygon()
	NavigationServer2D.map_changed

func generate_world():
	var noise_val
	var update = {}
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			noise_val = noise.get_noise_2d(x,y)
			
			if noise_val > 0.5:
				update[Vector2i(x,y)] = dirt_layer
			
			#setting all grass tiles
			elif noise_val > -0.2:
				update[Vector2i(x,y)] = grass_layer
		
			# setting sand
			elif noise_val > -0.4:
				update[Vector2i(x,y)] = sand_layer
			else: 
				update[Vector2i(x,y)] = water_layer
				
	changeset = BetterTerrain.create_terrain_changeset(tilemap, update)
