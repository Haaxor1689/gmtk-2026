extends Node

@onready var viewport_container := $SubViewportContainer
@onready var subviewport := $SubViewportContainer/SubViewport
@onready var level_container := $SubViewportContainer/SubViewport/LevelContainer
@onready var player_camera := $SubViewportContainer/SubViewport/PlayerCamera
@onready var scene_fade: ColorRect = $SceneFade

@onready var tilemap: TileMapLayer = $SubViewportContainer/SubViewport/GlobalTilemap

var player: GridNode
signal fuel_changed(new_fuel: float)

var current_level: Node = null
var current_level_path: String
var current_player_spawn_position := Vector2.ZERO

var input_disabled := true
var is_changing_scene := false

const PLAYER_SCENE: PackedScene = preload("res://src/characters/player.tscn")

const TILE_SIZE: int = 16
const GRID_NODE_BASE_Z_INDEX: int = 50
const SCENE_FADE_DURATION: float = 0.5

@export var initial_player_spawn_position := Vector2(-216, 8)

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

func change_scene(new_level: PackedScene, new_player_position: Vector2) -> void:
	if is_changing_scene:
		return

	is_changing_scene = true
	input_disabled = true

	await fade_to_black()

	current_level_path = new_level.resource_path
	current_player_spawn_position = new_player_position

	if current_level:
		current_level.queue_free()

	current_level = new_level.instantiate()
	level_container.add_child(current_level)

	if player:
		player.global_position = new_player_position
		player.cool_fuel = 100.0
		align_to_grid(player)
		player_camera.snap_to(player.global_position)

	await fade_from_black()

	input_disabled = false
	is_changing_scene = false

func fade_to_black() -> void:
	if !scene_fade || !current_level_path:
		return

	var tween := create_tween()
	tween.tween_property(scene_fade, "modulate:a", 1.0, SCENE_FADE_DURATION)
	await tween.finished
	print("Fade to black complete")

func fade_from_black() -> void:
	if !scene_fade:
		return

	print("Fading from black")
	var tween := create_tween()
	tween.tween_property(scene_fade, "modulate:a", 0.0, SCENE_FADE_DURATION)
	await tween.finished
	print("Fade from black complete")

func _ready() -> void:
	scene_fade.visible = true
	player = PLAYER_SCENE.instantiate() as GridNode
	subviewport.add_child(player)
	change_scene(load("res://src/levels/level1.tscn"), initial_player_spawn_position)
