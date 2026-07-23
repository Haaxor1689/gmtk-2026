extends GridNode

var inputs = {
  "up" = Vector2.UP,
  "down" = Vector2.DOWN,
  "left" = Vector2.LEFT,
  "right" = Vector2.RIGHT
}

func _unhandled_input(event: InputEvent) -> void:
  for dir in inputs.keys():
    if event.is_action_pressed(dir):
      Global.try_move(self, inputs[dir], true)

func _ready() -> void:
  super._ready()
  Global.player = self

func _exit_tree() -> void:
  if Global.player == self:
    Global.player = null
