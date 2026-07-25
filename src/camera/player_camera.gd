extends Camera2D

var actual_cam_pos := Vector2.ZERO
var follow_cam_pos := Vector2.ZERO
var shake_time := 0.0

@export var follow_speed := 3.0
@export var enable_train_shake := true
@export var sway_amplitude := 1.8
@export var sway_frequency := 0.28
@export var bob_amplitude := 0.8
@export var bob_frequency := 0.55
@export var rumble_amplitude := 0.35
@export var rumble_frequency := 3.0

func _ready() -> void:
  follow_cam_pos = global_position
  actual_cam_pos = global_position

func snap_to(target_position: Vector2) -> void:
  follow_cam_pos = target_position
  actual_cam_pos = target_position
  var cam_subpixel_offset = actual_cam_pos.round() - actual_cam_pos
  Global.viewport_container.material.set_shader_parameter("cam_offset", cam_subpixel_offset)
  global_position = actual_cam_pos.round()

func _process(delta: float) -> void:
  if Global.player == null:
    return

  shake_time += delta

  follow_cam_pos = follow_cam_pos.lerp(Global.player.global_position, delta * follow_speed)
  var shake_offset := Vector2.ZERO
  if enable_train_shake:
    shake_offset = get_train_shake(shake_time)

  actual_cam_pos = follow_cam_pos + shake_offset

  var cam_subpixel_offset = actual_cam_pos.round() - actual_cam_pos

  Global.viewport_container.material.set_shader_parameter("cam_offset", cam_subpixel_offset)

  global_position = actual_cam_pos.round()

func get_train_shake(time: float) -> Vector2:
  var sway_x = sin(time * TAU * sway_frequency) * sway_amplitude
  var bob_y = sin(time * TAU * bob_frequency + PI / 3.0) * bob_amplitude
  var rumble_x = sin(time * TAU * rumble_frequency) * rumble_amplitude

  return Vector2(sway_x + rumble_x, bob_y)
