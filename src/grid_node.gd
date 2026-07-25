class_name GridNode
extends Node2D

var grid_pos: Vector2 = Vector2.ZERO
@export var is_pushable: bool = false
@export var is_solid: bool = true
@export var push_cost: float = 2.0
@export var z_index_offset: int = 0

func _ready() -> void:
	Global.align_to_grid(self)
	Global.objects.append(self)
	update_z_index()

func _exit_tree() -> void:
	Global.objects.erase(self)

func update_z_index() -> void:
	# Update z_index based on Y position for proper depth sorting
	# Base offset ensures objects are above background/walls but can be below foreground
	z_index = Global.GRID_NODE_BASE_Z_INDEX + int(global_position.y) + z_index_offset

func grid_to_global(grid_position: Vector2) -> Vector2:
	var local_center = Global.tilemap.map_to_local(grid_position)
	return Global.tilemap.to_global(local_center)

func try_move(direction: Vector2, pushed_by: GridNode) -> GridNode:
	if !is_pushable && pushed_by != Global.player:
		return null

	var new_position := grid_pos + direction

	# Check for collisions with collideable tilemaps
	for t in Global.tilemaps:
		if t.is_solid:
			if t.get_cell_source_id(new_position) != -1:
				return null

	# Check for collisions with other GridNodes
	for obj in Global.objects:
		if obj.is_solid && obj.grid_pos == new_position:
			if self == Global.player:
				return obj.try_move(direction, self)
			else:
				animate_move()
				return null

	grid_pos = new_position
	animate_move(grid_to_global(new_position))

	return self

func animate_move(target_position := grid_to_global(grid_pos)) -> void:
	# Kill any existing tween
	if get_meta("move_tween", []).size() > 0:
		for t in get_meta("move_tween"):
			t.kill()

	# Reset rotation and scale
	rotation = 0.0
	scale = Vector2.ONE

	var tween = create_tween()
	var scale_tween = create_tween()

	var tweens := [tween, scale_tween]
	set_meta("move_tween", tweens)
	for t in tweens:
		t.set_trans(Tween.TRANS_QUAD)
		t.set_ease(Tween.EASE_OUT)

	# Position tween with arc motion
	var start_pos := global_position
	tween.tween_method(
		func(t: float):
			var horizontal := start_pos.lerp(target_position, t)
			var arc_height := sin(t * PI) * 6.0 # Small upward arc, 10 pixels max
			global_position = horizontal + Vector2(0, -arc_height)
			update_z_index()
	, 0.0, 1.0, 0.3)

	# Scale: expand for first 0.15s, then reverse for next 0.15s
	scale_tween.tween_property(self, "scale", Vector2(0.9, 1.1), 0.15)
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.15)
