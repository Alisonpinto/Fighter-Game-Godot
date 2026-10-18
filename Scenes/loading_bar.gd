
extends Control

@onready var loading_bar: ProgressBar = $LoadingBar

var progress: float = 0.0
var load_duration: float = 2.5
var elapsed: float = 0.0

func _ready() -> void:
	loading_bar.min_value = 0
	loading_bar.max_value = 100
	loading_bar.value = 0

func _process(delta: float) -> void:
	elapsed += delta
	progress = min((elapsed / load_duration) * 100.0, 100.0)

	loading_bar.value = progress

	if elapsed >= load_duration:
		get_tree().change_scene_to_file(
            "res://Scenes/splash_screen.tscn"
		)
