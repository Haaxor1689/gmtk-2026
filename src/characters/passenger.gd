@tool
extends GridNode

@onready var name_label: Label = $NameLabel
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
@export var task_id: String

func _ready() -> void:
	super._ready()

	if texture == null and sprite_2d and sprite_2d.texture:
		texture = sprite_2d.texture
	_update_sprite()
	_update_name_label()
	if passenger_name == "Prosperos":
		name_label.position.y -= 5
	elif passenger_name == "Prole":
		name_label.position.y += 5

	area_shape_entered.connect(_on_area_shape_entered)
	area_shape_exited.connect(_on_area_shape_exited)


func _update_sprite() -> void:
	if sprite_2d && texture:
		sprite_2d.texture = texture

func _update_name_label() -> void:
	if name_label && passenger_name:
		name_label.text = passenger_name

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
		name_label.visible = true
		return

	if _is_in_shape(alert_range, local_shape_index) and task_id:
		var lines = Lines.barks[lines_set].task_available.random()
		Global.play_line(Lines.Args.new(lines[0]).node(self).audio(load(lines[1]) as AudioStream))

func _on_area_shape_exited(_area_rid: RID, area: Area2D, _area_shape_index: int, local_shape_index: int) -> void:
	if area != Global.player:
		return

	if _is_in_shape(label_range, local_shape_index):
		name_label.visible = false
