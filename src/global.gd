extends Node

@onready var viewport_container := $SubViewportContainer

@onready var tilemap: TileMapLayer = $SubViewportContainer/SubViewport/GlobalTilemap

var player: GridNode

var current_level: Node = null

const TILE_SIZE: int = 16

var tilemaps: Array[TileMapLayer] = []

var objects: Array[GridNode] = []

func align_to_grid(node: GridNode) -> void:
	var local := tilemap.to_local(node.global_position)
	var cell := tilemap.local_to_map(local)
	var local_center := tilemap.map_to_local(cell)
	node.global_position = tilemap.to_global(local_center)
	node.grid_pos = cell
	print("Aligned ", node.name, " to grid at ", cell)

func try_move(node: GridNode, direction: Vector2) -> bool:
	var new_position := node.grid_pos + direction

	for t in tilemaps:
		if t.is_collidable:
			if t.get_cell_source_id(new_position) != -1:
				return false

	var local_center := tilemap.map_to_local(new_position)
	var target_position := tilemap.to_global(local_center)

	node.grid_pos = new_position

	# Kill any existing tween
	if node.get_meta("move_tween", []).size() > 0:
		for t in node.get_meta("move_tween"):
			t.kill()

	# Reset rotation and scale to defaults
	node.rotation = 0.0
	node.scale = Vector2.ONE

	var tween = create_tween()
	var scale_tween = create_tween()

	var tweens := [tween, scale_tween]
	node.set_meta("move_tween", tweens)
	for t in tweens:
		t.set_trans(Tween.TRANS_QUAD)
		t.set_ease(Tween.EASE_OUT)

	# Position tween with arc motion
	var start_pos := node.global_position
	tween.tween_method(
		func(t: float):
			var horizontal := start_pos.lerp(target_position, t)
			var arc_height := sin(t * PI) * 6.0 # Small upward arc, 10 pixels max
			node.global_position = horizontal + Vector2(0, -arc_height)
	, 0.0, 1.0, 0.3)

	# Scale: expand for first 0.15s, then reverse for next 0.15s
	scale_tween.tween_property(node, "scale", Vector2(0.9, 1.1), 0.15)
	scale_tween.tween_property(node, "scale", Vector2.ONE, 0.15)

	print("Moved to: ", new_position)
	return true

func change_level(new_level: PackedScene) -> void:
	if current_level:
		current_level.queue_free()

	current_level = new_level.instantiate()

	$SubViewportContainer/SubViewport/LevelContainer.add_child(current_level)

func _ready() -> void:
	change_level(load("res://src/levels/level1.tscn"))
