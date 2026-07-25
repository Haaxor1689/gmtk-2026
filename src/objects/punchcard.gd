extends GridNode

func try_move(_direction: Vector2, pushed_by: GridNode) -> GridNode:
  if pushed_by != Global.player:
    return null

  Global.collect_item(name, $Sprite2D.texture.resource_path)
  queue_free()
  return null
