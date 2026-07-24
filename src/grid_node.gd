class_name GridNode
extends Node2D

var grid_pos: Vector2 = Vector2.ZERO
@export var is_pushable: bool = false
@export var push_cost: float = 2.0

func _ready() -> void:
	Global.align_to_grid(self)
	Global.objects.append(self)
	update_z_index()

func _exit_tree() -> void:
	Global.objects.erase(self)

func update_z_index() -> void:
	# Update z_index based on Y position for proper depth sorting
	# Base offset ensures objects are above background/walls but can be below foreground
	z_index = Global.GRID_NODE_BASE_Z_INDEX + int(global_position.y)

func try_move(direction: Vector2, pushed_by: GridNode = null) -> float:
	if pushed_by != null:
		if !is_pushable:
			return 0

	var new_position := self.grid_pos + direction

	for t in Global.tilemaps:
		if t.is_collidable:
			if t.get_cell_source_id(new_position) != -1:
				return push_cost

	for obj in Global.objects:
		if obj.grid_pos == new_position:
			return obj.try_move(direction, self)

	var local_center = Global.tilemap.map_to_local(new_position)
	var target_position = Global.tilemap.to_global(local_center)

	self.grid_pos = new_position

	# Kill any existing tween
	if self.get_meta("move_tween", []).size() > 0:
		for t in self.get_meta("move_tween"):
			t.kill()

	# Reset rotation and scale to defaults
	self.rotation = 0.0
	self.scale = Vector2.ONE

	var tween = create_tween()
	var scale_tween = create_tween()

	var tweens := [tween, scale_tween]
	self.set_meta("move_tween", tweens)
	for t in tweens:
		t.set_trans(Tween.TRANS_QUAD)
		t.set_ease(Tween.EASE_OUT)

	# Position tween with arc motion
	var start_pos := self.global_position
	tween.tween_method(
		func(t: float):
			var horizontal := start_pos.lerp(target_position, t)
			var arc_height := sin(t * PI) * 6.0 # Small upward arc, 10 pixels max
			self.global_position = horizontal + Vector2(0, -arc_height)
	, 0.0, 1.0, 0.3)
	tween.tween_callback(self.update_z_index)

	# Scale: expand for first 0.15s, then reverse for next 0.15s
	scale_tween.tween_property(self, "scale", Vector2(0.9, 1.1), 0.15)
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.15)

	print("Moved to: ", new_position)
	return push_cost
