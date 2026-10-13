
extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -450.0

var gravity: float = float(
	ProjectSettings.get_setting("physics/2d/default_gravity")
)

func _ready() -> void:
	var body_visual = get_node_or_null("Polygon2D")
	if body_visual:
		body_visual.polygon = PackedVector2Array([
			Vector2(-16, -64),
			Vector2(16, -64),
			Vector2(16, 0),
			Vector2(-16, 0)
		])
		body_visual.color = Color.DODGER_BLUE

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	move_and_slide()
