extends GridNode

@export var stored_fuel := 50

func try_move(_direction: Vector2, pushed_by: GridNode = null) -> float:
	if pushed_by != Global.player || stored_fuel <= 0:
		return 0

	stored_fuel -= 10
	return -10
