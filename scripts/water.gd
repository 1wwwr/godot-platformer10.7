extends Area2D

@export var lift_strength: float = -3920.0 # 向上浮力，负数=Y向上；数值越大浮力越强
var player_in: bool = false
var player_body: CharacterBody2D = null

func _on_body_entered(body):
	if body is CharacterBody2D:
		player_in = true
		player_body = body

func _on_body_exited(body):
	if body is CharacterBody2D:
		player_in = false
		player_body = null

func _physics_process(delta):
	if player_in and player_body != null:
		# 在气流里，叠加向上浮力
		player_body.velocity.y += lift_strength * delta

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
