
extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -450.0
@export var max_health: int = 100
@export var attack_damage: int = 10
@export var attack_range: float = 100.0

var health: int = 100
var gravity: float = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
var is_attacking: bool = false

@onready var health_bar: ProgressBar = get_node_or_null("/root/Main/HUD/ProgressBarP2")
@onready var opponent: CharacterBody2D = get_node_or_null("../Player")


func _ready() -> void:
	health = max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("p2_jump") and is_on_floor():
		velocity.y = jump_velocity

	var direction := Input.get_axis("p2_move_left", "p2_move_right")
	velocity.x = direction * speed
	move_and_slide()

	if Input.is_action_just_pressed("p2_attack") and not is_attacking:
		perform_attack()


func perform_attack() -> void:
	is_attacking = true

	if opponent and is_instance_valid(opponent):
		if global_position.distance_to(opponent.global_position) <= attack_range:
			opponent.take_damage(attack_damage)

	await get_tree().create_timer(0.15).timeout
	is_attacking = false


func take_damage(amount: int) -> void:
	health = max(health - amount, 0)

	if health_bar:
		health_bar.value = health

	if health <= 0:
		velocity = Vector2.ZERO
		print("Player 2 knocked out!")
