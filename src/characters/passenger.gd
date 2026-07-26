@tool
extends GridNode

@onready var name_label: Label = $NameLabel
@export var passenger_name: String:
	set(value):
		passenger_name = value
		_update_name_label()

@export var texture: Texture2D:
	set(value):
		texture = value
		_update_sprite()


@export var has_dialog: bool = false
@export var willpower: float = 1.0
@export var base_happiness: float = 0.0

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	if texture == null and sprite_2d and sprite_2d.texture:
		texture = sprite_2d.texture
	_update_sprite()
	_update_name_label()

func _update_sprite() -> void:
	if sprite_2d && texture:
		sprite_2d.texture = texture

func _update_name_label() -> void:
	if name_label && passenger_name:
		name_label.text = passenger_name

func interact() -> void:
	if has_dialog:
		_trigger_dialog()
	else:
		_pickup_passenger()

func _trigger_dialog() -> void:
	# TODO: Connect to your dialogue manager scene.
	print("Triggering dialogue for: ", passenger_name if passenger_name != "" else "Unnamed Passenger")

func _pickup_passenger() -> void:
	print("Picked up passenger: ", passenger_name if passenger_name != "" else "Unnamed Passenger")

func get_score_contribution() -> float:
	return base_happiness
