extends Node

@onready var viewport_container := $SubViewportContainer

@onready var tilemap: TileMapLayer = $SubViewportContainer/SubViewport/GlobalTilemap

var player: GridNode

var current_level: Node = null

const TILE_SIZE: int = 16
const GRID_NODE_BASE_Z_INDEX: int = 50

var tilemaps: Array[TileMapLayer] = []

var objects: Array[GridNode] = []

func align_to_grid(node: GridNode) -> void:
	var local := tilemap.to_local(node.global_position)
	var cell := tilemap.local_to_map(local)
	var local_center := tilemap.map_to_local(cell)
	node.global_position = tilemap.to_global(local_center)
	node.grid_pos = cell
	node.update_z_index()
	print("Aligned ", node.name, " to grid at ", cell)

func change_scene(new_level: PackedScene) -> void:
	if current_level:
		current_level.queue_free()

	current_level = new_level.instantiate()

	$SubViewportContainer/SubViewport/LevelContainer.add_child(current_level)

func _ready() -> void:
	change_scene(load("res://src/levels/level1.tscn"))
