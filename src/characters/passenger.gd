@tool
extends GridNode

@export var passenger_name: String:
	set(value):
		passenger_name = value
		_update_name_label()

@onready var sprite_2d: Sprite2D = $Sprite2D
@export var texture: Texture2D:
	set(value):
		texture = value
		_update_sprite()

@onready var label_range: CollisionShape2D = $LabelRange
@onready var alert_range: CollisionShape2D = $AlertRange

@export var lines_set := "prole_m"

@export var wants_item: InventoryItem
@export var time_to_get_item: float = 15.0

var item_timer: Timer = null
var item_tick_timer: Timer = null

var _is_name_label_visible: bool = false

func _ready() -> void:
	super._ready()
	is_pushable = wants_item == null

	if texture == null and sprite_2d and sprite_2d.texture:
		texture = sprite_2d.texture
	_update_sprite()
	_update_name_label()

	area_shape_entered.connect(_on_area_shape_entered)
	area_shape_exited.connect(_on_area_shape_exited)


func _clear_item_request_state() -> void:
	if item_timer and is_instance_valid(item_timer):
		item_timer.stop()
		item_timer.queue_free()
	item_timer = null

	if item_tick_timer and is_instance_valid(item_tick_timer):
		item_tick_timer.stop()
		item_tick_timer.queue_free()
	item_tick_timer = null

	Global.floating_label(0.0, "", alert_range)

	wants_item = null


func _fulfill_wanted_item() -> bool:
	if wants_item == null:
		return false

	if !Global.consume_item(wants_item):
		return false

	_clear_item_request_state()
	is_pushable = true
	return true


func try_move(direction: Vector2, pushed_by: GridNode) -> GridNode:
	if pushed_by == Global.player and wants_item:
		if _fulfill_wanted_item():
			animate_move()
			return self

	return super.try_move(direction, pushed_by)


func _update_sprite() -> void:
	if sprite_2d && texture:
		sprite_2d.texture = texture

func _update_name_label() -> void:
	if _is_name_label_visible:
		_show_name_label()

func _show_name_label() -> void:
	if passenger_name.is_empty():
		_hide_name_label()
		return
	Global.floating_label(-1.0, passenger_name, label_range)

func _hide_name_label() -> void:
	Global.floating_label(0.0, "", label_range)

func _trigger_dialog() -> void:
	# TODO: Connect to your dialogue manager scene.
	print("Triggering dialogue for: ", passenger_name if passenger_name != "" else "Unnamed Passenger")

func _pickup_passenger() -> void:
	print("Picked up passenger: ", passenger_name if passenger_name != "" else "Unnamed Passenger")

func _is_in_shape(expected_shape: CollisionShape2D, idx: int) -> bool:
	var owner_id := shape_find_owner(idx)
	if owner_id == -1:
		return false

	return shape_owner_get_owner(owner_id) == expected_shape

func _on_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, local_shape_index: int) -> void:
	if area != Global.player:
		return

	if _is_in_shape(label_range, local_shape_index):
		_is_name_label_visible = true
		_show_name_label()

	elif _is_in_shape(alert_range, local_shape_index) && wants_item && !item_timer:
		item_timer = Timer.new()
		item_timer.wait_time = time_to_get_item
		item_timer.one_shot = true

		var line = Lines.barks[lines_set].task_available.random()
		await Global.play_line(Lines.Args.new(line[0]).node(self).audio(load(line[1])))

		var label := VBoxContainer.new()
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.alignment = BoxContainer.ALIGNMENT_CENTER

		var icon_center := CenterContainer.new()
		icon_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_child(icon_center)

		var icon := TextureRect.new()
		icon.texture = wants_item.item_texture
		icon.custom_minimum_size = Vector2(16, 16)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_center.add_child(icon)

		var text := Label.new()
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		text.add_theme_constant_override("outline_size", 6)
		label.add_child(text)

		var update_countdown := func() -> void:
			if item_timer and is_instance_valid(item_timer):
				text.text = "%ss" % [maxi(int(ceil(max(item_timer.time_left, 0.0))), 0)]
			else:
				text.text = "0s"

		item_timer.timeout.connect(func():
			_clear_item_request_state()

			# TODO: Handle what happens when the player fails to deliver the item in time.
		)
		add_child(item_timer)
		item_timer.start()
		update_countdown.call()

		item_tick_timer = Timer.new()
		item_tick_timer.wait_time = 0.2
		item_tick_timer.one_shot = false
		item_tick_timer.timeout.connect(update_countdown)
		add_child(item_tick_timer)
		item_tick_timer.start()

		Global.floating_label(time_to_get_item, label, alert_range, 28.0)


func _on_area_shape_exited(_area_rid: RID, area: Area2D, _area_shape_index: int, local_shape_index: int) -> void:
	if area != Global.player || item_timer:
		return

	if _is_in_shape(label_range, local_shape_index):
		_is_name_label_visible = false
		_hide_name_label()
