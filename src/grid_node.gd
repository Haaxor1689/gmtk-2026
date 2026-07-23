class_name GridNode
extends Node2D

var grid_pos: Vector2 = Vector2.ZERO
@export var is_pushable: bool = false
@export var is_breakable: bool = false
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

func check_breakable() -> void:
	print("Checking if ", name, " is breakable: ", is_breakable)
		
