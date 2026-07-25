extends MarginContainer

@onready var progress_bar := $TextureProgressBar

const LOW_FUEL_THRESHOLD := 30.0
const NORMAL_COLOR := Color(1, 1, 1, 1)
const LOW_FUEL_PULSE_COLOR := Color(1, 0.25, 0.25, 1)
const FUEL_GAIN_FLASH_COLOR := Color(0.35, 1, 0.35, 1)
const MIN_SHAKE_DISTANCE := 1.2
const MAX_SHAKE_DISTANCE := 8.0
const MID_RANGE_SHAKE_BONUS := 1.4
const SHAKE_STEP_DURATION := 0.04
const GAIN_FLASH_STEP_DURATION := 0.12

var low_fuel_tween: Tween
var shake_tween: Tween
var fuel_gain_tween: Tween
var base_position := Vector2.ZERO
var previous_fuel := 0.0

func _ready() -> void:
	base_position = position
	previous_fuel = progress_bar.value
	Global.fuel_changed.connect(on_fuel_changed)
	on_fuel_changed(progress_bar.value)

func on_fuel_changed(new_fuel: float) -> void:
	var fuel_lost = max(previous_fuel - new_fuel, 0.0)
	var fuel_gained = max(new_fuel - previous_fuel, 0.0)
	previous_fuel = new_fuel

	progress_bar.value = new_fuel

	if fuel_gained > 0.0:
		flash_gain(new_fuel < LOW_FUEL_THRESHOLD)
	else:
		if fuel_gain_tween:
			fuel_gain_tween.kill()
			fuel_gain_tween = null

		if new_fuel < LOW_FUEL_THRESHOLD:
			start_low_fuel_pulse()
		else:
			stop_low_fuel_pulse()

	if fuel_lost > 0.0:
		shake_bar(fuel_lost)

func flash_gain(resume_low_fuel_pulse: bool) -> void:
	if fuel_gain_tween:
		fuel_gain_tween.kill()
		fuel_gain_tween = null

	if low_fuel_tween:
		low_fuel_tween.kill()
		low_fuel_tween = null

	fuel_gain_tween = create_tween()
	fuel_gain_tween.tween_property(progress_bar, "tint_progress", FUEL_GAIN_FLASH_COLOR, GAIN_FLASH_STEP_DURATION)
	fuel_gain_tween.tween_property(progress_bar, "tint_progress", NORMAL_COLOR, GAIN_FLASH_STEP_DURATION)
	fuel_gain_tween.finished.connect(func() -> void:
		fuel_gain_tween = null
		if resume_low_fuel_pulse:
			start_low_fuel_pulse()
	)

func start_low_fuel_pulse() -> void:
	if low_fuel_tween and low_fuel_tween.is_running():
		return

	low_fuel_tween = create_tween().set_loops()
	low_fuel_tween.tween_property(progress_bar, "tint_progress", LOW_FUEL_PULSE_COLOR, 0.4)
	low_fuel_tween.tween_property(progress_bar, "tint_progress", NORMAL_COLOR, 0.4)

func stop_low_fuel_pulse() -> void:
	if low_fuel_tween:
		low_fuel_tween.kill()
		low_fuel_tween = null

	progress_bar.tint_progress = NORMAL_COLOR

func shake_bar(fuel_lost: float) -> void:
	# Tune 1..5 fuel loss to feel distinct: 1 is subtle, 2/2.5 get an extra bump, 5 is max.
	var normalized_loss = clamp((fuel_lost - 1.0) / 4.0, 0.0, 1.0)
	var base_shake = lerpf(MIN_SHAKE_DISTANCE, MAX_SHAKE_DISTANCE, normalized_loss)
	var mid_range_boost = smoothstep(1.5, 2.5, clamp(fuel_lost, 1.5, 2.5)) * MID_RANGE_SHAKE_BONUS
	var shake_distance = min(base_shake + mid_range_boost, MAX_SHAKE_DISTANCE)

	if shake_tween:
		shake_tween.kill()

	position = base_position
	shake_tween = create_tween()
	shake_tween.tween_property(self, "position", base_position + Vector2(-shake_distance, 0), SHAKE_STEP_DURATION)
	shake_tween.tween_property(self, "position", base_position + Vector2(shake_distance, 0), SHAKE_STEP_DURATION)
	shake_tween.tween_property(self, "position", base_position + Vector2(-shake_distance * 0.5, 0), SHAKE_STEP_DURATION)
	shake_tween.tween_property(self, "position", base_position, SHAKE_STEP_DURATION)
