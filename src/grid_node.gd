extends Node2D
class_name GridNode

var grid_pos: Vector2 = Vector2.ZERO
@export var is_pushable: bool = false

func _ready() -> void:
	Global.align_to_grid(self)
	Global.objects.append(self)

func _exit_tree() -> void:
	Global.objects.erase(self)
