extends Node2D
class_name GridNode

var grid_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	Global.align_to_grid(self)
