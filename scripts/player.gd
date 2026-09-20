extends CharacterBody2D

@export var player_speed: float = 300
@export var jump_velocity: float = -400.0
@export var gravity: float = 980.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# 计算重力
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 跳跃
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
	
	# 左右平移
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * player_speed
	else:
		velocity.x = move_toward(velocity.x, 0, player_speed)
	
	# 开始移动
	move_and_slide()
