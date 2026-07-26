extends Node

# Holds a set of [text, sound_path] pairs and returns a random one.
# Usage: Lines.barks.jeevis.notify_control.random()
class LineGroup:
	var _data: Array
	func _init(data: Array) -> void:
		_data = data
	func random() -> Array:
		return _data[randi() % _data.size()]


# Typed options for Global.play_line
class Args:
	extends RefCounted

	var _line: String
	var _node: Node2D = null
	var _offset: float = 32.0
	var _audio: AudioStream = null

	func _init(value: String) -> void:
		_line = value

	func node(value: Node2D) -> Args:
		_node = value
		return self

	func offset(value: float) -> Args:
		_offset = value
		return self

	func audio(value: AudioStream) -> Args:
		_audio = value
		return self


# ---------------------------------------------------------------------------
# Speaker bark groups
# ---------------------------------------------------------------------------

class _JeevisBarks:
	var notify_control: LineGroup
	var notify_time: LineGroup
	var notify_task: LineGroup
	var fuel_warning: LineGroup
	var end_fuel_zero: LineGroup

	func _init() -> void:
		notify_control = LineGroup.new([
			["Duty calls.", "res://assets/sounds/Jeevis_0001.wav"],
			["Onward.", "res://assets/sounds/Jeevis_0002.wav"],
			["Tea can wait.", "res://assets/sounds/Jeevis_0003.wav"],
			["Let's get to task.", "res://assets/sounds/Jeevis_0004.wav"],
			["Workie workie.", "res://assets/sounds/Jeevis_0005.wav"],
		])
		notify_time = LineGroup.new([
			["Time runs short...", "res://assets/sounds/Jeevis_0011.wav"],
			["Almost out of time.", "res://assets/sounds/Jeevis_0012.wav"],
			["Not much time left.", "res://assets/sounds/Jeevis_0013.wav"],
			["Timey-wimey bulldongles.", "res://assets/sounds/Jeevis_0014.wav"],
			["Tick Tick Tick!", "res://assets/sounds/Jeevis_0015.wav"],
		])
		notify_task = LineGroup.new([
			["As you wish.", "res://assets/sounds/Jeevis_0021.wav"],
			["It's on the list.", "res://assets/sounds/Jeevis_0022.wav"],
			["My pleasure.", "res://assets/sounds/Jeevis_0023.wav"],
			["I'll get right on that.", "res://assets/sounds/Jeevis_0024.wav"],
			["I have a duty to serve.", "res://assets/sounds/Jeevis_0025.wav"],
		])
		fuel_warning = LineGroup.new([
			["I need more Cool-Coal.", "res://assets/sounds/Jeevis_0031.wav"],
			["Oh dear, almost out of fuel.", "res://assets/sounds/Jeevis_0032.wav"],
			["Cool-Coal is running low.", "res://assets/sounds/Jeevis_0033.wav"],
			["Need a fuel refill soon.", "res://assets/sounds/Jeevis_0034.wav"],
			["Where's a Cool-Coal station when you need one?", "res://assets/sounds/Jeevis_0035.wav"],
		])
		end_fuel_zero = LineGroup.new([
			["Seems I've run out of fuel... Oh bother...", "res://assets/sounds/Jeevis_0041.wav"],
			["My Cool-Coal supply is at an end. And so... am... I...", "res://assets/sounds/Jeevis_0042.wav"],
			["Out of fuel? Oh no...", "res://assets/sounds/Jeevis_0043.wav"],
			["That's it... I'm... out...", "res://assets/sounds/Jeevis_0044.wav"],
			["Cool-Coal tank... Empty...", "res://assets/sounds/Jeevis_0045.wav"],
		])


class _ChazBarks:
	var game_over: LineGroup

	func _init() -> void:
		game_over = LineGroup.new([
			["That's it, too many demerits, you are DE-COMMISSIONED! HAHAHA!", "res://assets/sounds/Chaz_0001.wav"],
			["Dreams do come true, you hit your demerit quota. Time to shut down.", "res://assets/sounds/Chaz_0002.wav"],
			["Oh goodie, you've maxxed out on demerits. To the trash bin with you! Haha!", "res://assets/sounds/Chaz_0003.wav"],
			["Look at you, collecting demerits like Cool-Coal. Rest In Peace, Jeevis. Muahaha.", "res://assets/sounds/Chaz_0004.wav"],
			["Oh my, that's a lot of demerits. Enough to warrant a shut down I believe. Hahaha!", "res://assets/sounds/Chaz_0005.wav"],
		])


class _ProleMBarks:
	var task_available: LineGroup
	var task_complete: LineGroup

	func _init() -> void:
		task_available = LineGroup.new([
			["Have you got the time?", "res://assets/sounds/Prole_M_0001.wav"],
			["I need a little help.", "res://assets/sounds/Prole_M_0002.wav"],
			["Service, please!", "res://assets/sounds/Prole_M_0003.wav"],
			["I have a task for you.", "res://assets/sounds/Prole_M_0004.wav"],
			["Can I get some help?", "res://assets/sounds/Prole_M_0005.wav"],
		])
		task_complete = LineGroup.new([
			["How kind.", "res://assets/sounds/Prole_M_0011.wav"],
			["Much appreciated.", "res://assets/sounds/Prole_M_0012.wav"],
			["Perfect!", "res://assets/sounds/Prole_M_0013.wav"],
			["Thank you, kindly.", "res://assets/sounds/Prole_M_0014.wav"],
			["What great service!", "res://assets/sounds/Prole_M_0015.wav"],
		])


class _ProleMUBarks:
	var task_available: LineGroup
	var task_complete: LineGroup

	func _init() -> void:
		task_available = LineGroup.new([
			["Where's that stupid robot?", "res://assets/sounds/Prole_M_U_0001.wav"],
			["Hey, bucket head, over here!", "res://assets/sounds/Prole_M_U_0002.wav"],
			["Where's the coal guzzler?", "res://assets/sounds/Prole_M_U_0003.wav"],
			["Get over here you tin toy!", "res://assets/sounds/Prole_M_U_0004.wav"],
			["Where's the job thief?", "res://assets/sounds/Prole_M_U_0005.wav"],
		])
		task_complete = LineGroup.new([
			["That's enough.", "res://assets/sounds/Prole_M_U_0011.wav"],
			["Yeah, fine, whatever.", "res://assets/sounds/Prole_M_U_0012.wav"],
			["Got it, so piss off.", "res://assets/sounds/Prole_M_U_0013.wav"],
			["Yeh... Off with you...", "res://assets/sounds/Prole_M_U_0014.wav"],
			["Great, now go away.", "res://assets/sounds/Prole_M_U_0015.wav"],
		])


class _ProleWBarks:
	var task_available: LineGroup
	var task_complete: LineGroup

	func _init() -> void:
		task_available = LineGroup.new([
			["Yoo hoo, over here!", "res://assets/sounds/Prole_W_0001.wav"],
			["Have a moment?", "res://assets/sounds/Prole_W_0002.wav"],
			["Assistance pretty please.", "res://assets/sounds/Prole_W_0003.wav"],
			["I need some help.", "res://assets/sounds/Prole_W_0004.wav"],
			["Can anyone help me?", "res://assets/sounds/Prole_W_0005.wav"],
		])
		task_complete = LineGroup.new([
			["Oh wonderful!", "res://assets/sounds/Prole_W_0011.wav"],
			["Thank you so much!", "res://assets/sounds/Prole_W_0012.wav"],
			["So kind of you.", "res://assets/sounds/Prole_W_0013.wav"],
			["What a blessing you are.", "res://assets/sounds/Prole_W_0014.wav"],
			["Aren't you helpful.", "res://assets/sounds/Prole_W_0015.wav"],
		])


class _ProleWUBarks:
	var task_available: LineGroup
	var task_complete: LineGroup

	func _init() -> void:
		task_available = LineGroup.new([
			["Where's the rust-bringer?", "res://assets/sounds/Prole_W_U_0001.wav"],
			["I need a steam-head over here.", "res://assets/sounds/Prole_W_U_0002.wav"],
			["Hey, bot, come here.", "res://assets/sounds/Prole_W_U_0003.wav"],
			["Any tin toys about?", "res://assets/sounds/Prole_W_U_0004.wav"],
			["Hey tin head, over here.", "res://assets/sounds/Prole_W_U_0005.wav"],
		])
		task_complete = LineGroup.new([
			["Yeah, fine... shoo.", "res://assets/sounds/Prole_W_U_0011.wav"],
			["Mehhh... go away.", "res://assets/sounds/Prole_W_U_0012.wav"],
			["Oh right right, bye.", "res://assets/sounds/Prole_W_U_0013.wav"],
			["Okay then, bye bye.", "res://assets/sounds/Prole_W_U_0014.wav"],
			["You think you're special?", "res://assets/sounds/Prole_W_U_0015.wav"],
		])


class _ProspMBarks:
	var task_available: LineGroup
	var task_complete: LineGroup

	func _init() -> void:
		task_available = LineGroup.new([
			["Where is that robot?", "res://assets/sounds/Prosp_M_0001.wav"],
			["Robot! Over here!", "res://assets/sounds/Prosp_M_0002.wav"],
			["Service... SERVICE!", "res://assets/sounds/Prosp_M_0003.wav"],
			["You, come HERE!", "res://assets/sounds/Prosp_M_0004.wav"],
			["I require ASSISTANCE!", "res://assets/sounds/Prosp_M_0005.wav"],
		])
		task_complete = LineGroup.new([
			["That'll do...", "res://assets/sounds/Prosp_M_0011.wav"],
			["Grand, off with you.", "res://assets/sounds/Prosp_M_0012.wav"],
			["I suppose that's it.", "res://assets/sounds/Prosp_M_0013.wav"],
			["Is that the best you could do?", "res://assets/sounds/Prosp_M_0014.wav"],
			["Acceptable... for now.", "res://assets/sounds/Prosp_M_0015.wav"],
		])


class _ProspMUBarks:
	var task_available: LineGroup
	var task_complete: LineGroup
	var task_add: LineGroup

	func _init() -> void:
		task_available = LineGroup.new([
			["You there! The bowl of piss!", "res://assets/sounds/Prosp_M_U_0001.wav"],
			["Hey you pissant tin brick!", "res://assets/sounds/Prosp_M_U_0002.wav"],
			["Come here you wobbling oven...", "res://assets/sounds/Prosp_M_U_0003.wav"],
			["Come 'ere you punch card cobbler!", "res://assets/sounds/Prosp_M_U_0004.wav"],
			["Tinny Toy, c'mere... COME HERE!", "res://assets/sounds/Prosp_M_U_0005.wav"],
		])
		task_complete = LineGroup.new([
			["That it? Piss... OFF!", "res://assets/sounds/Prosp_M_U_0011.wav"],
			["Stop abusing my space.", "res://assets/sounds/Prosp_M_U_0012.wav"],
			["Go on... git!", "res://assets/sounds/Prosp_M_U_0013.wav"],
			["You still here? What the...", "res://assets/sounds/Prosp_M_U_0014.wav"],
			["You broken? Move on tin pisser...", "res://assets/sounds/Prosp_M_U_0015.wav"],
		])
		task_add = LineGroup.new([
			["You ain't done, got another for ya.", "res://assets/sounds/Prosp_M_U_0021.wav"],
		])


class _ProspWBarks:
	var task_available: LineGroup
	var task_complete: LineGroup

	func _init() -> void:
		task_available = LineGroup.new([
			["A service robot, how droll.", "res://assets/sounds/Prosp_W_0001.wav"],
			["Don't you know how to serve me?", "res://assets/sounds/Prosp_W_0002.wav"],
			["Why aren't you attending me already?", "res://assets/sounds/Prosp_W_0003.wav"],
			["Can you not see I'm in need?", "res://assets/sounds/Prosp_W_0004.wav"],
			["Come here at once!", "res://assets/sounds/Prosp_W_0005.wav"],
		])
		task_complete = LineGroup.new([
			["What do you want, applause?", "res://assets/sounds/Prosp_W_0011.wav"],
			["You did it, good for you.", "res://assets/sounds/Prosp_W_0012.wav"],
			["Right then, ta-ta.", "res://assets/sounds/Prosp_W_0013.wav"],
			["Oh you did it, oooh.", "res://assets/sounds/Prosp_W_0014.wav"],
			["This blind tin toys need a tune up", "res://assets/sounds/Prosp_W_0015.wav"],
		])


class _ProspWUBarks:
	var task_available: LineGroup
	var task_complete: LineGroup
	var task_add: LineGroup

	func _init() -> void:
		task_available = LineGroup.new([
			["Robot, here. NOW!", "res://assets/sounds/Prosp_W_U_0001.wav"],
			["Where is that tin piss pot?", "res://assets/sounds/Prosp_W_U_0002.wav"],
			["How long must I wait for such horrid service?", "res://assets/sounds/Prosp_W_U_0003.wav"],
			["Do I look like a peasant to you? Come here, now!", "res://assets/sounds/Prosp_W_U_0004.wav"],
			["Robot! Get over here...", "res://assets/sounds/Prosp_W_U_0005.wav"],
		])
		task_complete = LineGroup.new([
			["These robots need more legislation... To remove their rights.", "res://assets/sounds/Prosp_W_U_0011.wav"],
			["My toaster is more capable than you.", "res://assets/sounds/Prosp_W_U_0012.wav"],
			["I've had better service from toilet bots.", "res://assets/sounds/Prosp_W_U_0013.wav"],
			["Knowing that you touched this disgusts me.", "res://assets/sounds/Prosp_W_U_0014.wav"],
			["Absolutely pathetic showing... Do better...", "res://assets/sounds/Prosp_W_U_0015.wav"],
		])
		task_add = LineGroup.new([
			["You know what, I thought of something else for you.", "res://assets/sounds/Prosp_W_U_0021.wav"],
		])


class _BanditMBarks:
	var grabs_something: LineGroup
	var gets_caught: LineGroup

	func _init() -> void:
		grabs_something = LineGroup.new([
			["Yoink!", "res://assets/sounds/Bandit_M_0001.wav"],
			["I'll take that!", "res://assets/sounds/Bandit_M_0002.wav"],
			["Thank you, it's mine now!", "res://assets/sounds/Bandit_M_0003.wav"],
			["You don't need this!", "res://assets/sounds/Bandit_M_0004.wav"],
			["It's not for me, it's for my family! HA HA!", "res://assets/sounds/Bandit_M_0005.wav"],
		])
		gets_caught = LineGroup.new([
			["Oh woe is me, captured by the evil robot!", "res://assets/sounds/Bandit_M_0011.wav"],
			["Now my family will starve, because of YOU...", "res://assets/sounds/Bandit_M_0012.wav"],
			["No no, I made a mistake, I thought it belonged to me.", "res://assets/sounds/Bandit_M_0013.wav"],
			["What? I took nothing. NOTHING! This is an outrage!", "res://assets/sounds/Bandit_M_0014.wav"],
			["Who are they going to believe? Me or the capitalist pig's toy?", "res://assets/sounds/Bandit_M_0015.wav"],
		])


class _EngineerWBarks:
	var task_available: LineGroup
	var task_complete: LineGroup

	func _init() -> void:
		task_available = LineGroup.new([
			["Hey, Jeevis, got a minute?", "res://assets/sounds/Engineer_W_0001.wav"],
			["Need your help over here, Jeevis.", "res://assets/sounds/Engineer_W_0002.wav"],
			["Jeevis, can I get a hand?", "res://assets/sounds/Engineer_W_0003.wav"],
			["Something's broken and I need your help.", "res://assets/sounds/Engineer_W_0004.wav"],
			["You got a minute to spare?", "res://assets/sounds/Engineer_W_0005.wav"],
		])
		task_complete = LineGroup.new([
			["That'll do, Jeevis, that'll do.", "res://assets/sounds/Engineer_W_0011.wav"],
			["Much obliged, Jeevis.", "res://assets/sounds/Engineer_W_0012.wav"],
			["Well ain't you a saint, thanks Jeevis.", "res://assets/sounds/Engineer_W_0013.wav"],
			["Thank you, Jeevis. Much appreciated.", "res://assets/sounds/Engineer_W_0014.wav"],
			["Great job, ya saved the day, Jeevis.", "res://assets/sounds/Engineer_W_0015.wav"],
		])


# ---------------------------------------------------------------------------
# Barks container — all speaker groups under one namespace
# ---------------------------------------------------------------------------

class _Barks:
	var jeevis: _JeevisBarks
	var chaz: _ChazBarks
	var prole_m: _ProleMBarks
	var prole_m_u: _ProleMUBarks
	var prole_w: _ProleWBarks
	var prole_w_u: _ProleWUBarks
	var prosp_m: _ProspMBarks
	var prosp_m_u: _ProspMUBarks
	var prosp_w: _ProspWBarks
	var prosp_w_u: _ProspWUBarks
	var bandit_m: _BanditMBarks
	var engineer_w: _EngineerWBarks

	func _init() -> void:
		jeevis = _JeevisBarks.new()
		chaz = _ChazBarks.new()
		prole_m = _ProleMBarks.new()
		prole_m_u = _ProleMUBarks.new()
		prole_w = _ProleWBarks.new()
		prole_w_u = _ProleWUBarks.new()
		prosp_m = _ProspMBarks.new()
		prosp_m_u = _ProspMUBarks.new()
		prosp_w = _ProspWBarks.new()
		prosp_w_u = _ProspWUBarks.new()
		bandit_m = _BanditMBarks.new()
		engineer_w = _EngineerWBarks.new()


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

var barks: _Barks

func _ready() -> void:
	barks = _Barks.new()
