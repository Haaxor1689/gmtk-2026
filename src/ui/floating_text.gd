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

func _process(_delta: float) -> void:
	if _follow_node and is_instance_valid(_follow_node):
		global_position = _follow_node.global_position + Vector2(0.0, -_y_offset)
	else:
		var vp_size := get_viewport().get_visible_rect().size
		var screen_pos := Vector2(vp_size.x * 0.5, vp_size.y - _SCREEN_BOTTOM_MARGIN)
		global_position = get_viewport().get_canvas_transform().affine_inverse() * screen_pos

func play_line(args: Lines.Args) -> void:
	_follow_node = args._node
	_y_offset = args._offset
	if args._node and is_instance_valid(args._node):
		global_position = args._node.global_position + Vector2(0.0, -args._offset)
	else:
		var vp_size := get_viewport().get_visible_rect().size
		var screen_pos := Vector2(vp_size.x * 0.5, vp_size.y - _SCREEN_BOTTOM_MARGIN)
		global_position = get_viewport().get_canvas_transform().affine_inverse() * screen_pos
	label.text = ""

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
