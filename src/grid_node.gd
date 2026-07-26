class_name GridNode
extends Area2D

var grid_pos: Vector2 = Vector2.ZERO
@export var is_pushable: bool = false
@export var is_solid: bool = true
@export var push_cost: float = 2.0
@export var z_index_offset: int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	Global.align_to_grid(self)
	Global.objects.append(self)
	update_z_index()

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return

	Global.objects.erase(self)

func update_z_index() -> void:
	# Update z_index based on Y position for proper depth sorting
	# Base offset ensures objects are above background/walls but can be below foreground
	z_index = Global.GRID_NODE_BASE_Z_INDEX + int(global_position.y) + z_index_offset

func grid_to_global(grid_position: Vector2) -> Vector2:
	var local_center = Global.tilemap.map_to_local(grid_position)
	return Global.tilemap.to_global(local_center)

func try_move(direction: Vector2, pushed_by: GridNode) -> GridNode:
	if !is_pushable && pushed_by != self:
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
	if has_meta("move_tween"):
		get_meta("move_tween").kill()

	# Reset rotation and scale
	rotation = 0.0
	scale = Vector2.ONE

	var tween = create_tween()
	set_meta("move_tween", tween)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	var arc_mult := 0.0
	if self == Global.player:
		arc_mult = 6.0
	elif global_position == target_position:
		arc_mult = 2.0

	# Position tween with arc motion
	var start_pos := global_position
	tween.tween_method(
		func(t: float):
			var horizontal := start_pos.lerp(target_position, t)
			var arc_height := sin(t * PI) * arc_mult
			global_position = horizontal + Vector2(0, -arc_height)
			update_z_index()
	, 0.0, 1.0, 0.3)
