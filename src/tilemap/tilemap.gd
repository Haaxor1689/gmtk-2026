extends TileMapLayer

@export var is_collidable: bool = false


func _ready() -> void:
	Global.tilemaps.append(self)

func _exit_tree() -> void:
	Global.tilemaps.erase(self)
