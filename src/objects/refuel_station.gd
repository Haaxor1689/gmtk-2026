extends GridNode

@export var stored_fuel := 50.0

@onready var sprite := $Sprite2D
@onready var sprite_depleted := $DepletedSprite2D
@onready var status_label : Label = $status_text
@onready var label_timer : Timer = $label_timer
@onready var fuel_step := push_cost

func try_move(_direction: Vector2, pushed_by: GridNode) -> GridNode:
	animate_move()

	if pushed_by != Global.player:
		return null

	elif stored_fuel <= 0:
		update_status_label("Station is Empty!")

	elif Global.player.cool_fuel == 100.0:
		update_status_label("Full on Fuel!")

	push_cost = fuel_step
	var fuel_to_add = max(push_cost, Global.player.cool_fuel - 100.0)

	stored_fuel += fuel_to_add
	push_cost = fuel_to_add

	if stored_fuel <= 0:
		sprite.visible = false
		sprite_depleted.visible = true

	return self

func update_status_label(text: String) -> void:
	status_label.text = text
	status_label.visible = true
	label_timer.start()

func _on_label_timer_timeout() -> void:
	status_label.visible = false
