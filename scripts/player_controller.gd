extends CharacterBody2D

#3
enum State {
	IDLE,
	RUNNING,
	JUMP,
	FALL,
}

@export_category("移动参数")
@export var double_press_interval := 0.3
@export var move_speed: float = 100.0
@export var acceleration: float = 600.0
@export var deceleration: float = 800.0
@export var jump_velocity: float = -230.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var flying : bool = false
var last_space_press_time := -1000

#add dash1
var is_dashing = false
@export var dash_speed: float = 1000.0
@export var dash_duration := 0.15



func _physics_process(delta: float) -> void:
	
	#use dash
	handle_dash()
	
#2
func tick_physics(state:State, delta:float) -> void:
	var direction := Input.get_axis("move_left","move_right")
	if is_on_floor():
		if is_zero_approx(direction) and is_zero_approx(velocity.x):
			animation_player.play("idle")
		else:
			animation_player.play("running")
	else:
		animation_player.play("jump")
		
	if not is_zero_approx(direction):
		sprite.flip_h = direction > 0
	
	if !flying:
		apply_gravity(delta)
		handle_jump()
	else:
		handle_vertical_movement(delta)
	
	handle_horizontal_movement(delta)
	
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_vertical_movement(delta:float) -> void:
	var direction := Input.get_axis("squat", "jump")
	var target_speed := direction * jump_velocity
	
	if direction != 0.0:
		velocity.y = move_toward(
				velocity.y,
				target_speed,
				acceleration * delta
		)
	else:
		velocity.y = move_toward(
				velocity.y,
				0.0,
				acceleration * delta
		)
	
func handle_horizontal_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	var target_speed := direction * move_speed

	if direction != 0.0:
		velocity.x = move_toward(
				velocity.x,
				target_speed,
				acceleration * delta
		)
	else:
		velocity.x = move_toward(
				velocity.x,
				0.0,
				deceleration * delta
		)

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity


		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fly") and !event.is_echo():
		handle_space_pressed()
	
func handle_space_pressed() -> void:
	var current_time := Time.get_ticks_msec()
	var elapsed_time := current_time - last_space_press_time

	if elapsed_time <= double_press_interval * 1000.0:
		flying = not flying
		last_space_press_time = -1000
	else:
		last_space_press_time = current_time

# dash1
func handle_dash():
	var dash_direction = Input.get_axis("move_left","move_right")
	
	if Input.is_action_just_pressed("dash") and not is_dashing:
		is_dashing = true
		
		if dash_direction == 0:
			dash_direction = 1
			
		velocity.x = dash_direction * dash_speed
		
		await get_tree().create_timer(dash_duration).timeout
		is_dashing = false
		velocity.x = 0
		
		
#3
func get_next_state(state:State) -> State:
	var direction := Input.get_axis("move_left","move_right")
	var is_still := is_zero_approx(direction) and is_zero_approx(velocity.x)
	match state:
		State.IDLE:
			if not is_still:
				return State.RUNNING
			
			
		State.RUNNING:
			if is_still:
				return State.IDLE
			
		State.JUMP:
			pass
			
		State.FALL:
			pass
			
	return state
		
		
func transition_state(from: State, to: State) -> void:
	match to:
		State.IDLE:
			animation_player.play("idle")
			
		State.RUNNING:
			animation_player.play("running")
