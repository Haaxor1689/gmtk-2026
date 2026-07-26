@tool
extends GridNode

@onready var sprite_2d: Sprite2D = $Sprite2D
@export var texture: Texture2D:
	set(value):
		texture = value
		_update_sprite()

@export var item_data: InventoryItem

func _ready() -> void:
	super._ready()

	if texture == null and sprite_2d and sprite_2d.texture:
		texture = sprite_2d.texture
	_update_sprite()

func _update_sprite() -> void:
	if sprite_2d and texture:
		sprite_2d.texture = texture

func try_move(_direction: Vector2, pushed_by: GridNode) -> GridNode:
	animate_move()

	if pushed_by != Global.player:
		return null

	if item_data:
		Global.collect_item(item_data)

	return self
