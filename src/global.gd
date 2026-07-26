extends Node

@onready var viewport_container := $SubViewportContainer
@onready var subviewport := $SubViewportContainer/SubViewport
@onready var level_container := $SubViewportContainer/SubViewport/LevelContainer
@onready var ui_layer: Control = $UI
@onready var player_camera := $SubViewportContainer/SubViewport/PlayerCamera
@onready var scene_fade: ColorRect = $SceneFade

@onready var tilemap: TileMapLayer = $SubViewportContainer/SubViewport/GlobalTilemap
@onready var game_over_label: Label = $UI/game_over_label
@onready var game_over_sound: AudioStreamPlayer = $game_over_sfx
@onready var main_theme: AudioStreamPlayer = $main_theme

const PLAYER_SCENE: PackedScene = preload("res://src/characters/player.tscn")
var player: GridNode
@export var initial_player_spawn_position := Vector2(-216, 8)

signal fuel_changed(new_fuel: float)
signal inventory_changed()

var current_level: Node = null

var restart_level_path: String
var restart_spawn_position := Vector2.ZERO
var restart_inventory: Array[InventoryItem] = []
var restart_fuel := 100.0

var current_inventory: Array[InventoryItem] = []

var input_disabled := true

const SCENE_FADE_DURATION := 0.5
var is_changing_scene := false

const FLOATING_TEXT_SCENE: PackedScene = preload("res://src/ui/floating_text.tscn")
var playing_floating_texts: Dictionary = {}

const TILE_SIZE := 16
const GRID_NODE_BASE_Z_INDEX := 50
const LOW_FUEL_THRESHOLD := 30.0

var tilemaps: Array[TileMapLayer] = []
var objects: Array[GridNode] = []

func align_to_grid(node: GridNode) -> void:
	var local := tilemap.to_local(node.global_position)
	var cell := tilemap.local_to_map(local)
	var local_center := tilemap.map_to_local(cell)
	node.global_position = tilemap.to_global(local_center)
	node.grid_pos = cell
	node.update_z_index()

func change_scene(new_level: PackedScene, new_player_position: Vector2) -> void:
	if is_changing_scene:
		return

	is_changing_scene = true
	disable_player_input()

	await fade_to_black()

	restart_level_path = new_level.resource_path
	restart_spawn_position = new_player_position

	restart_inventory = current_inventory.duplicate()
	inventory_changed.emit()

	restart_fuel = player.cool_fuel
	fuel_changed.emit(restart_fuel)

	if current_level:
		current_level.queue_free()

	current_level = new_level.instantiate()
	level_container.add_child(current_level)

	if player:
		player.global_position = new_player_position
		align_to_grid(player)
		player_camera.snap_to(player.global_position)

	await fade_from_black()

	enable_player_input()
	is_changing_scene = false

func fade_to_black() -> void:
	if !scene_fade || !restart_level_path:
		return

	var tween := create_tween()
	tween.tween_property(scene_fade, "modulate:a", 1.0, SCENE_FADE_DURATION)
	await tween.finished

func fade_from_black() -> void:
	if !scene_fade:
		return

	print("Fading from black")
	var tween := create_tween()
	tween.tween_property(scene_fade, "modulate:a", 0.0, SCENE_FADE_DURATION)
	await tween.finished

func _ready() -> void:
	scene_fade.visible = true
	player = PLAYER_SCENE.instantiate() as GridNode
	subviewport.add_child(player)
	change_scene(load("res://src/levels/level4.tscn"), initial_player_spawn_position)

func disable_player_input() -> void:
	input_disabled = true

func enable_player_input() -> void:
	input_disabled = false
	var entry: Array = Lines.barks.jeevis.notify_control.random()
	play_line(
		Lines.Args.new(entry[0])
			.node(player)
			.audio(load(entry[1]) as AudioStream)
	)

func play_line(args: Lines.Args) -> void:
	if args == null || args._line.is_empty():
		return

	var node_key := args._node.get_instance_id() if args._node else -1

	var active = playing_floating_texts.get(node_key, null)
	if active:
		active.queue_free()
		playing_floating_texts.erase(node_key)

	var floating_text := FLOATING_TEXT_SCENE.instantiate()
	playing_floating_texts[node_key] = floating_text
	ui_layer.add_child(floating_text)
	await floating_text.play_line(args)
	if playing_floating_texts.get(node_key, null) == floating_text:
		playing_floating_texts.erase(node_key)

	if is_instance_valid(floating_text):
		floating_text.queue_free()

func floating_label(duration: float, content: Variant, node: Node2D = null, y_offset: float = 32.0) -> Node:
	var node_key := node.get_instance_id() if node else -1

	var active = playing_floating_texts.get(node_key, null)
	if active:
		active.queue_free()
		playing_floating_texts.erase(node_key)

	var floating_text := FLOATING_TEXT_SCENE.instantiate()
	playing_floating_texts[node_key] = floating_text
	ui_layer.add_child(floating_text)

	if duration < 0.0:
		floating_text.floating_label(duration, content, node, y_offset)
		return floating_text

	await floating_text.floating_label(duration, content, node, y_offset)
	if playing_floating_texts.get(node_key, null) == floating_text:
		playing_floating_texts.erase(node_key)

	if is_instance_valid(floating_text):
		floating_text.queue_free()

	return floating_text

func _is_same_inventory_item(a: InventoryItem, b: InventoryItem) -> bool:
	if a == null || b == null:
		return false

	if !a.resource_path.is_empty() && !b.resource_path.is_empty():
		return a.resource_path == b.resource_path

	return a == b

func has_item(item: InventoryItem) -> bool:
	if item == null:
		return false

	for owned_item in current_inventory:
		if _is_same_inventory_item(owned_item, item):
			return true

	return false

func collect_item(item: InventoryItem) -> void:
	if item == null:
		return

	if has_item(item):
		return

	current_inventory.append(item)
	SFX.play(SFX.item_pickup)
	inventory_changed.emit()

func consume_item(item: InventoryItem) -> bool:
	if item == null:
		return false

	for i in range(current_inventory.size()):
		if _is_same_inventory_item(current_inventory[i], item):
			current_inventory.remove_at(i)
			inventory_changed.emit()
			return true

	return false


func _on_timer_timeout() -> void:
	main_theme.stop()
	game_over_sound.play()
	fade_to_black()
	game_over_label.visible = true

	# Wait for the game over audio to finish before restarting
	await game_over_sound.finished

	get_tree().reload_current_scene()
