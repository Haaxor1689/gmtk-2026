extends GridNode

@export var stored_fuel := 50.0

@onready var sprite := $Sprite2D
@onready var sprite_depleted := $DepletedSprite2D

func try_move(_direction: Vector2, pushed_by: GridNode) -> GridNode:
	animate_move()

	if pushed_by != Global.player || stored_fuel <= 0:
		return null

	stored_fuel += push_cost

	if stored_fuel <= 0:
		sprite.visible = false
		sprite_depleted.visible = true

	return self
