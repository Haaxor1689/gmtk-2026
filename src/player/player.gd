extends GridNode

var cool_fuel: float = 100.0

@onready var fuel_label: Label = $fuel_label

var inputs = {
  "up" = Vector2.UP,
  "down" = Vector2.DOWN,
  "left" = Vector2.LEFT,
  "right" = Vector2.RIGHT
}

func _unhandled_input(event: InputEvent) -> void:
  for dir in inputs.keys():
    if event.is_action_pressed(dir):
      var cool_cost = Global.try_move(self, inputs[dir])
      update_fuel(-cool_cost)
	
func update_fuel(modifier) -> void:
  cool_fuel += modifier
  fuel_label.text = str(cool_fuel)

func _ready() -> void:
  super._ready()
  Global.player = self

func _exit_tree() -> void:
  if Global.player == self:
    Global.player = null
