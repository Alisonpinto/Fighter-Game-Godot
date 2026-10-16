
extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -450.0
@export var max_health: int = 100
@export var attack_damage: int = 10
@export var attack_range: float = 100.0

var health: int = 100
var gravity: float = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
var is_attacking: bool = false
var already_hit: bool = false

@onready var fighter_sprite: Sprite2D = get_node_or_null("Sprite2D2")
@onready var health_bar: ProgressBar = get_node_or_null("/root/Main/HUD/ProgressBarP1")
@onready var opponent: CharacterBody2D = get_node_or_null("../Player 2")


func _ready() -> void:
	health = max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health



func _physics_process(delta: float) -> void:
	var direction := 0.0

	if Input.is_physical_key_pressed(KEY_A):
		direction = -1.0
	elif Input.is_physical_key_pressed(KEY_D):
		direction = 1.0

	if direction != 0.0:
		global_position.x += direction * speed * delta
		print("P1 position: ", global_position)



func perform_attack() -> void:
	is_attacking = true
	already_hit = false

	if fighter_sprite:
		var original_position := fighter_sprite.position
		var tween := create_tween()
		tween.tween_property(fighter_sprite, "position:x", original_position.x + 12.0, 0.06)
		tween.tween_property(fighter_sprite, "position:x", original_position.x, 0.09)

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
		print("Player 1 knocked out!")
