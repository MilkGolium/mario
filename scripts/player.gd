extends CharacterBody2D

@export var player_speed: float = 300.0
@export var jump_velocity: float = -200.0

## 上升时的重力（跳起后往上冲）
@export var gravity_up: float = 200.0
## 下降时的重力（往下落，一般比上升大，手感更"干脆"）
@export var gravity_down: float = 1250.0
## 最大下落速度（可选，防止掉太快）
@export var max_fall_speed: float = 450.0

func _physics_process(delta: float) -> void:
	# —— 重力 ——
	if not is_on_floor():
		# 用速度方向判断上升 / 下降
		if velocity.y < 0.0:
			# 上升阶段（Godot 里 y 向上为负）
			velocity.y += gravity_up * delta
		else:
			# 下降阶段
			velocity.y += gravity_down * delta

		# 限制最大下落速度（可选）
		velocity.y = min(velocity.y, max_fall_speed)
	else:
		# 在地面：把竖直速度压住，防止累加 / 防止误判
		# 不要用 = 0，否则会丢失一点"站在斜面上"的手感，用 move_toward 更稳
		velocity.y = move_toward(velocity.y, 0.0, gravity_down * delta)

	# —— 跳跃 ——
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# —— 左右平移 ——
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * player_speed
	else:
		velocity.x = move_toward(velocity.x, 0, player_speed)

	# —— 移动 ——
	move_and_slide()
