extends GridNode

@onready var sprite := $Sprite2D
@onready var sprite_broken := $Sprite2D_broken

var is_broken := false

func try_move(direction: Vector2, pushed_by: GridNode = null) -> float:
	# If pushed by player
	if pushed_by != null and pushed_by == Global.player:
		return super.try_move(direction, self)

	sprite.visible = false
	sprite_broken.visible = true
	is_broken = true
	return 0
