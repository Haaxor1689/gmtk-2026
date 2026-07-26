extends Node2D

@onready var label: Label = $Label
@onready var voice_line: AudioStreamPlayer = $VoiceLine

# Words are shown this fraction of the audio duration earlier, so text leads the speech
const _WORD_LEAD_FRACTION: float = 0.15
const _SCREEN_BOTTOM_MARGIN: float = 40.0
# Used to estimate display duration when no audio stream is provided
const _CHARS_PER_SECOND: float = 16.0

var _follow_node: Node2D = null
var _y_offset: float = 38.0
var _custom_canvas_item: CanvasItem = null

func _process(_delta: float) -> void:
	global_position = _get_target_position()

func _get_target_position() -> Vector2:
	if _follow_node and is_instance_valid(_follow_node):
		var world_pos := _follow_node.global_position + Vector2(0.0, -_y_offset)
		var container = Global.get("viewport_container")
		var camera = Global.get("player_camera")
		if container and camera and camera.has_method("world_to_viewport_pos_no_shake"):
			var viewport_screen_pos: Vector2 = camera.world_to_viewport_pos_no_shake(world_pos)
			var container_pos: Vector2 = container.position
			var container_scale: Vector2 = container.scale
			var root_screen_pos: Vector2 = container_pos + (viewport_screen_pos * container_scale)
			return get_viewport().get_canvas_transform().affine_inverse() * root_screen_pos
		return world_pos

	var vp_size := get_viewport().get_visible_rect().size
	var screen_pos := Vector2(vp_size.x * 0.5, vp_size.y - _SCREEN_BOTTOM_MARGIN)
	return get_viewport().get_canvas_transform().affine_inverse() * screen_pos

func _clear_custom_canvas_item() -> void:
	if _custom_canvas_item and is_instance_valid(_custom_canvas_item):
		_custom_canvas_item.queue_free()
	_custom_canvas_item = null

func _show_canvas_content(content: CanvasItem) -> void:
	var render_item: CanvasItem = content
	# Prefer rendering the original node so runtime updates (like countdown text)
	# continue to appear while the floating label is active.
	if render_item.get_parent() != null:
		render_item = content.duplicate() as CanvasItem
		if render_item == null:
			render_item = content

	if render_item.get_parent() != null:
		render_item.reparent(self)
	else:
		add_child(render_item)

	if render_item is Node2D:
		(render_item as Node2D).position = Vector2.ZERO
	elif render_item is Control:
		var control_item := render_item as Control
		control_item.position = -0.5 * control_item.get_combined_minimum_size()

	render_item.show()
	_custom_canvas_item = render_item

func floating_label(duration: float, content: Variant, follow_node: Node2D = null, y_offset: float = 32.0) -> void:
	_follow_node = follow_node
	_y_offset = y_offset
	global_position = _get_target_position()

	label.hide()
	label.text = ""
	_clear_custom_canvas_item()

	if content is CanvasItem:
		_show_canvas_content(content as CanvasItem)
	else:
		label.text = str(content)
		label.show()

	if duration < 0.0:
		return

	await get_tree().create_timer(max(duration, 0.0)).timeout
	label.hide()
	_clear_custom_canvas_item()

func play_line(args: Lines.Args) -> void:
	_follow_node = args._node
	_y_offset = args._offset
	global_position = _get_target_position()
	label.text = ""
	_clear_custom_canvas_item()

	var effective_duration: float = 0.0
	if args._audio != null:
		voice_line.stream = args._audio
		effective_duration = max(args._audio.get_length(), 0.0)
		voice_line.play()
	else:
		effective_duration = float(args._line.length()) / _CHARS_PER_SECOND

	label.show()

	var words: PackedStringArray = args._line.split(" ", false)

	if words.is_empty() or effective_duration <= 0.0:
		label.text = args._line
		if args._audio != null:
			await voice_line.finished
		else:
			await get_tree().create_timer(effective_duration).timeout
		label.hide()
		return

	var total_chars: int = 0
	for w in words:
		total_chars += w.length()

	# Spread words across only the leading portion of the duration so each word
	# appears slightly before it is spoken. Delay per word scales with its length.
	var display_duration: float = effective_duration * (1.0 - _WORD_LEAD_FRACTION)

	for i in range(words.size()):
		label.text = " ".join(words.slice(0, i + 1))
		if args._audio != null and not voice_line.playing:
			break
		var delay: float = display_duration * float(words[i].length()) / float(total_chars)
		await get_tree().create_timer(delay).timeout

	if args._audio != null:
		await voice_line.finished
	else:
		await get_tree().create_timer(effective_duration * _WORD_LEAD_FRACTION).timeout

	label.hide()
