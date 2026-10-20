
extends Node2D


func _ready() -> void:
	var start_button = $StartButton
	var exit_button = $ExitButton

	if start_button is Button:
		start_button.pressed.connect(_on_start_button_pressed)
	else:
		push_error("StartButton must be a Button node!")

	if exit_button is Button:
		exit_button.pressed.connect(_on_exit_button_pressed)
	else:
		push_error("ExitButton must be a Button node!")


func _on_start_button_pressed() -> void:
	var error = get_tree().change_scene_to_file(
        "res://Scenes/story_scene.tscn"
	)

	if error != OK:
		push_error(
            "Could not open story_scene.tscn. Check the scene path."
		)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
