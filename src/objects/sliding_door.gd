extends GridNode

var is_open := false
var is_moving := false

@export var open_scene: String
@export var player_spawn_position := Vector2.ZERO

@onready var sprite := $Sprite2D
@onready var sprite_material := sprite.material as ShaderMaterial
@onready var close_timer := $CloseTimer

func _ready():
	super._ready()
	update_cutoff()
	close_timer.wait_time = 5.0
	close_timer.one_shot = true
	close_timer.timeout.connect(close_door)

func _process(_delta: float):
	# If root or camera moves and you want the cutoff to follow, update it
	update_cutoff()

func update_cutoff():
	# Use this node's global Y as the cutoff
	var cutoff_y := global_position.y - 38
	sprite_material.set_shader_parameter("cutoff_y", cutoff_y)

func try_move(_direction: Vector2, pushed_by: GridNode) -> GridNode:
	if pushed_by != Global.player:
		return null
	if is_moving || is_open:
		return null

	open_door()
	return self

func open_door():
	if open_scene:
		Global.change_scene(load(open_scene), player_spawn_position)
	is_moving = true
	var tween := create_tween()
	tween.tween_property(sprite, "position:y", sprite.position.y - 14, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		is_open = true;
		is_solid = false;
		is_moving = false;
		close_timer.start()
	)

func close_door():
	close_timer.stop()
	is_moving = true
	is_open = false;
	is_solid = true;
	var tween := create_tween()
	tween.tween_property(sprite, "position:y", sprite.position.y + 14, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func(): is_moving = false)
