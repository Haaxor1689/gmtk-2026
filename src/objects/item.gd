@tool
extends GridNode

@export var item_name: String:
  set(value):
    item_name = value
    _update_item_name()

@onready var sprite_2d: Sprite2D = $Sprite2D
@export var item_texture: Texture2D:
  set(value):
    item_texture = value
    _update_sprite()

func _ready() -> void:
  super._ready()
  _update_sprite()
  _update_item_name()

func _update_item_name() -> void:
  if item_name:
    name = item_name

func _update_sprite() -> void:
  if sprite_2d && item_texture:
    sprite_2d.texture = item_texture

func try_move(_direction: Vector2, pushed_by: GridNode) -> GridNode:
  if pushed_by != Global.player:
    return null

  Global.collect_item(name, item_texture.resource_path)
  queue_free()
  return null
