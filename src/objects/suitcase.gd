@tool
extends GridNode

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite_2d.frame = randi() % (sprite_2d.hframes * sprite_2d.vframes)
	super._ready()
