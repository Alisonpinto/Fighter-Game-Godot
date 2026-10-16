
extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -450.0
@export var max_health: int = 100
@export var attack_damage: int = 10
@export var attack_duration: float = 0.15

var health: int = 100
var gravity: float = float(
	ProjectSettings.get_setting("physics/2d/default_gravity")
)
var is_attacking: bool = false
var already_hit: bool = false

@onready var attack_area: Area2D = $AttackArea
@onready var health_bar: ProgressBar = get_node_or_null(
    "/root/Main/HUD/P1HealthBar"
)
@onready var fighter_sprite: Sprite2D = $Sprite2D2


func _ready() -> void:
	health = max_health
	attack_area.monitoring = false
	attack_area.body_entered.connect(_on_attack_area_body_entered)

	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed

	if Input.is_action_just_pressed("p1_attack") and not is_attacking:
		perform_attack()

	move_and_slide()


func perform_attack() -> void:
	is_attacking = true
	already_hit = false

	print("Player 1 punched!")

	var original_position: Vector2 = fighter_sprite.position
	var tween := create_tween()

	tween.tween_property(
		fighter_sprite,
		"position:x",
		original_position.x + 12.0,
		0.06
	)
	tween.tween_property(
		fighter_sprite,
		"position:x",
		original_position.x,
		0.09
	)

	attack_area.position.x = 35
	attack_area.monitoring = true

	for body in attack_area.get_overlapping_bodies():
		_try_hit(body)

	await tween.finished

	attack_area.monitoring = false
	is_attacking = false


func _on_attack_area_body_entered(body: Node2D) -> void:
	_try_hit(body)


func _try_hit(body: Node2D) -> void:
	if not is_attacking or already_hit or body == self:
		return

	if body.is_in_group("player2") and body.has_method("take_damage"):
		already_hit = true
		body.take_damage(attack_damage)
		print("Player 1 hit Player 2!")


func take_damage(amount: int) -> void:
	health = max(health - amount, 0)

	if health_bar:
		health_bar.value = health

	print("Player 1 health: ", health)

	if health == 0:
		print("Player 1 knocked out!")
