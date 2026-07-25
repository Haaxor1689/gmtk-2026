extends Node2D

@onready var label: Label = $Label
@onready var voice_line: AudioStreamPlayer = $VoiceLine

# Words are shown this fraction of the audio duration earlier, so text leads the speech
const _WORD_LEAD_FRACTION: float = 0.15
const _SCREEN_BOTTOM_MARGIN: float = 40.0
# Used to estimate display duration when no audio stream is provided
const _CHARS_PER_SECOND: float = 12.0
const _MIN_DURATION: float = 2.0

var _follow_node: Node2D = null
var _y_offset: float = 38.0

func _process(_delta: float) -> void:
	if _follow_node and is_instance_valid(_follow_node):
		global_position = _follow_node.global_position + Vector2(0.0, -_y_offset)
	else:
		var vp_size := get_viewport().get_visible_rect().size
		var screen_pos := Vector2(vp_size.x * 0.5, vp_size.y - _SCREEN_BOTTOM_MARGIN)
		global_position = get_viewport().get_canvas_transform().affine_inverse() * screen_pos

func play_line(line: String, follow_node: Node2D = null, y_offset: float = 38.0, voice_line_stream: AudioStream = null) -> void:
	_follow_node = follow_node
	_y_offset = y_offset
	if follow_node and is_instance_valid(follow_node):
		global_position = follow_node.global_position + Vector2(0.0, -y_offset)
	else:
		var vp_size := get_viewport().get_visible_rect().size
		var screen_pos := Vector2(vp_size.x * 0.5, vp_size.y - _SCREEN_BOTTOM_MARGIN)
		global_position = get_viewport().get_canvas_transform().affine_inverse() * screen_pos
	label.text = ""

	var effective_duration: float = 0.0
	if voice_line_stream != null:
		voice_line.stream = voice_line_stream
		effective_duration = max(voice_line_stream.get_length(), 0.0)
		voice_line.play()
	else:
		effective_duration = max(float(line.length()) / _CHARS_PER_SECOND, _MIN_DURATION)

	label.show()

	var words: PackedStringArray = line.split(" ", false)

	if words.is_empty() or effective_duration <= 0.0:
		label.text = line
		if voice_line_stream != null:
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
		if voice_line_stream != null and not voice_line.playing:
			break
		var delay: float = display_duration * float(words[i].length()) / float(total_chars)
		await get_tree().create_timer(delay).timeout

	if voice_line_stream != null:
		await voice_line.finished
	else:
		await get_tree().create_timer(effective_duration * _WORD_LEAD_FRACTION).timeout

	label.hide()
