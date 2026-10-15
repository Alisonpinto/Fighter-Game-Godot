
extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -450.0

var gravity: float = float(
	ProjectSettings.get_setting("physics/2d/default_gravity")
)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("p2_jump") and is_on_floor():
		velocity.y = jump_velocity

	var direction := Input.get_axis(
		"p2_move_left",
        "p2_move_right"
	)

	velocity.x = direction * speed

	move_and_slide()
