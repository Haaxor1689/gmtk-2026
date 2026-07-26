extends GridNode

@export var stored_fuel := 50.0

@onready var sprite := $Sprite2D
@onready var sprite_depleted := $DepletedSprite2D

@onready var fuel_step := push_cost

func try_move(_direction: Vector2, pushed_by: GridNode) -> GridNode:
	animate_move()

	if pushed_by != Global.player:
		return null

	elif Global.player.cool_fuel == 100.0:
		Global.play_line(
			Lines.Args.new("Full on Fuel!").node(self)
		)
		Global.play_line(
			Lines.Args.new("Station is Empty!").node(self)
		)


	if stored_fuel <= 0:
		sprite.visible = false
		sprite_depleted.visible = true
	else:
		var fuel_to_add = max(fuel_step, Global.player.cool_fuel - 100.0)
		stored_fuel += fuel_to_add
		push_cost = fuel_to_add

	return self
