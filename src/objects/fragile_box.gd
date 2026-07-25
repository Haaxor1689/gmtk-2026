extends GridNode

@onready var sprite := $Sprite2D
@onready var sprite_broken := $BrokenSprite2D

var is_broken := false

func try_move(direction: Vector2, pushed_by: GridNode) -> GridNode:
	if is_broken:
		return super.try_move(direction, self)

	# If pushed by player
	if pushed_by == Global.player:
		var moved_node = super.try_move(direction, self)
		if moved_node != self:
			set_broken()
		return moved_node
	else:
		set_broken()
		animate_move()
		return null


func set_broken() -> void:
	sprite.visible = false
	sprite_broken.visible = true
	is_broken = true
