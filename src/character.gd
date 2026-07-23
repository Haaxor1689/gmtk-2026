extends CharacterBody2D

const max_speed := 55
const acceleration := 5
const friction := 8


func _physics_process(delta: float) -> void:
  var input = Vector2(
    Input.get_action_strength('right') - Input.get_action_strength('left'),
    Input.get_action_strength('down') - Input.get_action_strength('up')
  ).normalized()

  var lerp_weight = delta * (acceleration if input else friction)
  velocity = velocity.lerp(input * max_speed, lerp_weight)

  move_and_slide()
