extends GridNode

@export var appearance_texture: Texture2D:
	set(value):
		appearance_texture = value
		_update_sprite()

@export var passenger_name: String = ""
@export var has_dialog: bool = false
@export var willpower: float = 1.0
@export var base_happiness: float = 0.0

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var name_label: Label = $name_label

func _ready() -> void:
	_update_sprite()
	name_label.text = passenger_name

func _update_sprite() -> void:
	if sprite_2d and appearance_texture:
		sprite_2d.texture = appearance_texture

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
