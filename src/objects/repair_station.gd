extends GridNode

var is_activated := false

func try_move(_direction: Vector2, pushed_by: GridNode) -> GridNode:
	animate_move()

	if pushed_by != Global.player:
		return null

	if is_activated:
		return null

	is_activated = true
	Global.show_end_game_screen()
	Global.disable_player_input()
	Global.fade_to_black()
	return self
