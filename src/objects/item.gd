@tool
extends GridNode

@export var item_data: InventoryItem:
  set(value):
    item_data = value
    _update_item_name()
    _update_sprite()

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
  super._ready()
  _update_sprite()
  _update_item_name()

func _update_item_name() -> void:
  if item_data and !item_data.item_name.is_empty():
    name = item_data.item_name

func _update_sprite() -> void:
  if sprite_2d && item_data && item_data.item_texture:
    sprite_2d.texture = item_data.item_texture

func try_move(_direction: Vector2, pushed_by: GridNode) -> GridNode:
  if pushed_by != Global.player:
    return null

  Global.collect_item(item_data)
  queue_free()
  return null
