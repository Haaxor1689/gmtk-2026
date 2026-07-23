extends Camera2D

var actual_cam_pos := Vector2.ZERO

func _process(delta: float) -> void:
  actual_cam_pos = position.lerp(Global.player.global_position, delta * 3)

  var cam_subpixel_offset = actual_cam_pos.round() - actual_cam_pos

  Global.viewport_container.material.set_shader_parameter("cam_offset", cam_subpixel_offset)

  global_position = actual_cam_pos.round()
