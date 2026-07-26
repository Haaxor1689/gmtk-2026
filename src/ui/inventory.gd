extends MarginContainer

@onready var inventory_list: HBoxContainer = $HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.inventory_changed.connect(on_item_collected)


func on_item_collected() -> void:
	for n in inventory_list.get_children():
		n.queue_free()

	for item in Global.current_inventory:
		if item == null:
			continue

		var item_container := VBoxContainer.new()
		item_container.alignment = BoxContainer.ALIGNMENT_CENTER

		# Create texture display
		var texture_rect := TextureRect.new()
		texture_rect.texture = item.item_texture
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.custom_minimum_size = Vector2(32, 32)
		item_container.add_child(texture_rect)

		# Create label with item name
		var item_label := Label.new()
		item_label.text = item.item_name
		item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_label.add_theme_constant_override("outline_size", 6)
		item_container.add_child(item_label)

		inventory_list.add_child(item_container)
