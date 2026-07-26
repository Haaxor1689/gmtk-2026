extends Node

const DEFAULT_POOL_SIZE := 8

var box_break: AudioStream = preload("res://assets/sfx/box_break.wav")
var character_steps: AudioStream = preload("res://assets/sfx/character_steps.wav")
var disembark: AudioStream = preload("res://assets/sfx/disembark.wav")
var door_open_sound: AudioStream = preload("res://assets/sfx/door_open_sound.wav")
var door_shut_sound: AudioStream = preload("res://assets/sfx/door_shut_sound.wav")
var error_sound: AudioStream = preload("res://assets/sfx/error_sound.wav")
var fail_task: AudioStream = preload("res://assets/sfx/fail_task.wav")
var fuel_recharge: AudioStream = preload("res://assets/sfx/fuel_recharge.wav")
var game_over: AudioStream = preload("res://assets/sfx/game_over.wav")
var item_pickup: AudioStream = preload("res://assets/sfx/item_pickup.wav")
var jeevis_leaking: AudioStream = preload("res://assets/sfx/jeevis_leaking.wav")
var object_bump: AudioStream = preload("res://assets/sfx/object_bump.wav")
var push_object: AudioStream = preload("res://assets/sfx/push_object.wav")

var _players: Array[AudioStreamPlayer] = []
var _next_player_index := 0

func _ready() -> void:
	_ensure_pool_size(DEFAULT_POOL_SIZE)

func _ensure_pool_size(size: int) -> void:
	while _players.size() < size:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)

func _get_available_player() -> AudioStreamPlayer:
	if _players.is_empty():
		_ensure_pool_size(DEFAULT_POOL_SIZE)

	for player in _players:
		if !player.playing:
			return player

	var player := _players[_next_player_index]
	_next_player_index = (_next_player_index + 1) % _players.size()
	player.stop()
	return player

func _is_same_stream(a: AudioStream, b: AudioStream) -> bool:
	if a == null || b == null:
		return false

	if !a.resource_path.is_empty() && !b.resource_path.is_empty():
		return a.resource_path == b.resource_path

	return a == b

func _get_player_playing_stream(stream: AudioStream) -> AudioStreamPlayer:
	for player in _players:
		if player.playing && _is_same_stream(player.stream, stream):
			return player

	return null

func play(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if stream == null:
		return

	var player := _get_player_playing_stream(stream)
	if player:
		player.stop()
	else:
		player = _get_available_player()

	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()
