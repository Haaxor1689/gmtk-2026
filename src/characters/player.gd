extends GridNode

var cool_fuel: float = 100.0
var restart_level_timer: Timer = null

var inputs = {
  "up" = Vector2.UP,
  "down" = Vector2.DOWN,
  "left" = Vector2.LEFT,
  "right" = Vector2.RIGHT
}

func _unhandled_input(event: InputEvent) -> void:
  if Global.input_disabled:
    return

  if event.is_action_pressed('restart_level'):
    # Start a timer to restart the level after a short delay
    restart_level_timer = Timer.new()
    restart_level_timer.wait_time = 2.0
    restart_level_timer.one_shot = true
    restart_level_timer.timeout.connect(restart_level)
    add_child(restart_level_timer)
    restart_level_timer.start()

  if event.is_action_released('restart_level'):
    # If the player releases the restart key before the timer finishes, stop the timer
    if restart_level_timer and restart_level_timer.is_stopped() == false:
      restart_level_timer.stop()
      restart_level_timer.queue_free()
      restart_level_timer = null


  for dir in inputs.keys():
    if event.is_action_pressed(dir):
      var moved_node = try_move(inputs[dir], self)
      if moved_node != null:
        update_fuel(-moved_node.push_cost)

func update_fuel(modifier) -> void:
  cool_fuel = clamp(cool_fuel + modifier, 0, 100)
  Global.fuel_changed.emit(cool_fuel)
  death_check()

func _ready() -> void:
  super._ready()
  Global.player = self

func _exit_tree() -> void:
  super._exit_tree()
  if Global.player == self:
    Global.player = null

func death_check() -> void:
  if cool_fuel <= 0:
    restart_level()

func restart_level() -> void:
  Global.current_inventory = Global.restart_inventory.duplicate()
  Global.change_scene(load(Global.restart_level_path), Global.restart_spawn_position)
