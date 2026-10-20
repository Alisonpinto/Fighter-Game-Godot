extends Control

# Select your actual fighting scene in the Inspector.
@export_file("*.tscn")
var gameplay_scene_path: String

@export var typing_speed: float = 35.0

var story_parts: Array[String] = [
	"Years ago, the world was ruled by the strongest fighters. Every city had its champion, and every champion fought for honor, power, and respect.",

	"But peace never lasted forever. A new rivalry was about to change everything.",

	"One fighter seeks strength to protect everything he loves. The other seeks power to prove that nobody can stand above him.",

    "Their paths are about to collide. Only one will rise as the ultimate champion. The battle begins now."
]

var current_part: int = 0
var typing: bool = false
var elapsed: float = 0.0

@onready var story_text: Label = $StoryPanel/StoryText
@onready var skip_button: Button = $StoryPanel/skip


func _ready() -> void:
	skip_button.pressed.connect(_on_skip_pressed)
	show_paragraph()


func show_paragraph() -> void:
	if current_part >= story_parts.size():
		start_game()
		return

	story_text.text = story_parts[current_part]
	story_text.visible_characters = 0
	elapsed = 0.0
	typing = true
	skip_button.text = "SKIP"


func _process(delta: float) -> void:
	if not typing:
		return

	elapsed += delta
	var count := int(elapsed * typing_speed)

	story_text.visible_characters = count

	if count >= story_text.get_total_character_count():
		finish_typing()


func finish_typing() -> void:
	typing = false
	story_text.visible_characters = -1
	skip_button.text = "CONTINUE"


func _on_skip_pressed() -> void:
	if typing:
		# First click: reveal the whole paragraph.
		finish_typing()
	else:
		# Next click: continue the story.
		current_part += 1
		show_paragraph()


func start_game() -> void:
	if gameplay_scene_path.is_empty():
		push_error("Select your fighting gameplay scene in the Inspector!")
		return

	get_tree().change_scene_to_file(gameplay_scene_path)
