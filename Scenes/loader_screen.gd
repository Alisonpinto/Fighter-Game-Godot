
extends Control

@onready var loading_bar: ProgressBar = $LoadingBar

const NEXT_SCENE_PATH: String = "res://Scenes/splash_screen.tscn"

# Cinematic pacing
const MINIMUM_LOAD_TIME: float = 5.5
const FINAL_HOLD_TIME: float = 1.4
const FADE_DURATION: float = 0.9

# Progress animation
const NORMAL_BAR_SPEED: float = 17.0
const FINAL_BAR_SPEED: float = 9.0

var elapsed: float = 0.0
var actual_progress: float = 0.0
var displayed_progress: float = 0.0

var scene_ready: bool = false
var failed: bool = false
var transition_started: bool = false
var final_hold: float = 0.0


func _ready() -> void:
	loading_bar.min_value = 0.0
	loading_bar.max_value = 100.0
	loading_bar.value = 0.0
	loading_bar.show_percentage = true

	# Start with a dark, cinematic screen.
	modulate.a = 0.0

	var intro := create_tween()
	intro.tween_property(self, "modulate:a", 1.0, 1.2)

	var error := ResourceLoader.load_threaded_request(
		NEXT_SCENE_PATH,
		"PackedScene",
		true
	)

	if error != OK:
		failed = true
		push_error("Could not start loading: " + NEXT_SCENE_PATH)


func _process(delta: float) -> void:
	elapsed += delta

	if failed or transition_started:
		return

	# Read actual resource-loading progress.
	if not scene_ready:
		var progress: Array = []

		var status := ResourceLoader.load_threaded_get_status(
			NEXT_SCENE_PATH,
			progress
		)

		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				if not progress.is_empty():
					actual_progress = float(progress[0]) * 100.0

			ResourceLoader.THREAD_LOAD_LOADED:
				actual_progress = 100.0
				scene_ready = true

			ResourceLoader.THREAD_LOAD_FAILED:
				failed = true
				push_error("Scene loading failed: " + NEXT_SCENE_PATH)
				return

			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				failed = true
				push_error("Invalid scene: " + NEXT_SCENE_PATH)
				return

	# Reveal progress slowly instead of racing to 100%.
	var target: float = actual_progress

	# Keep the final portion for the dramatic reveal.
	if scene_ready:
		target = 96.0

	var speed: float = NORMAL_BAR_SPEED

	if target >= 90.0:
		speed = FINAL_BAR_SPEED

	displayed_progress = move_toward(
		displayed_progress,
		target,
		speed * delta
	)

	loading_bar.value = displayed_progress

	# Don't transition until the real scene is loaded
	# and the cinematic minimum duration has elapsed.
	if (
		scene_ready
		and elapsed >= MINIMUM_LOAD_TIME
		and displayed_progress >= 95.0
	):
		final_hold += delta

		if final_hold >= FINAL_HOLD_TIME:
			_begin_transition()


func _begin_transition() -> void:
	if transition_started:
		return

	transition_started = true
	loading_bar.value = 100.0

	# Let the completed bar sit briefly before the reveal.
	await get_tree().create_timer(0.35).timeout

	var resource := ResourceLoader.load_threaded_get(
		NEXT_SCENE_PATH
	)

	var packed_scene := resource as PackedScene

	if packed_scene == null:
		failed = true
		push_error("Loaded resource is not a PackedScene.")
		return

	# Slow fade to black for a cinematic scene change.
	var tween := create_tween()
	tween.tween_property(
		self,
		"modulate:a",
		0.0,
		FADE_DURATION
	)

	await tween.finished

	var error := get_tree().change_scene_to_packed(packed_scene)

	if error != OK:
		failed = true
		push_error("Scene transition failed.")
