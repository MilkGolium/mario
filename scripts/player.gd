extends CharacterBody2D

## 玩家最大水平速度
@export var player_speed: float = 850.0

## 地面加速度（越大起步越快；想更"滑"就调小）
@export var ground_acceleration: float = 2200.0

## 地面减速度（越大松手停得越快；想滑行更远就调小）
@export var ground_deceleration: float = 1500.0

## 空中加速度（通常比地面小，空中控制弱，更接近 Mario）
@export var air_acceleration: float = 1200.0

## 空中减速度（通常比地面小，空中松手几乎保持原速）
@export var air_deceleration: float = 600.0

## 反向掉头时的额外倍率（越大掉头越干脆；1.0 = 与普通减速一致）
@export var turn_around_mult: float = 2.0

## 期望的跳跃高度（单位：像素）
@export var jump_height: float = 100.0

## 上升段耗时（单位：秒）；数值越小，上升到预期高度越快
@export var time_to_peak: float = 0.33
## 下降重力倍率（下降速度通常比上升更快，手感更干脆）
@export var fall_gravity_mult: float = 1.6

## 限制最大下落速度
@export var max_fall_speed: float = 900.0

# 由上面参数自动算出
var jump_velocity: float = 0.0
var gravity_up: float = 0.0
var gravity_down: float = 0.0

func _ready() -> void:
	jump_velocity = -2.0 * jump_height / time_to_peak
	gravity_up    =  2.0 * jump_height / (time_to_peak * time_to_peak)
	gravity_down  =  gravity_up * fall_gravity_mult

func _physics_process(delta: float) -> void:
	# —— 竖直：重力 ——
	if not is_on_floor():
		if velocity.y < 0.0:
			velocity.y += gravity_up * delta
		else:
			velocity.y += gravity_down * delta
		velocity.y = min(velocity.y, max_fall_speed)
	else:
		velocity.y = move_toward(velocity.y, 0.0, gravity_down * delta)

	# —— 跳跃 ——
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# —— 水平：带惯性的加减速 ——
	var direction := Input.get_axis("ui_left", "ui_right")
	var target_speed := direction * player_speed

	# 根据是否在地面，选择不同的加速度/减速度
	var accel: float
	var decel: float
	if is_on_floor():
		accel = ground_acceleration
		decel = ground_deceleration
	else:
		accel = air_acceleration
		decel = air_deceleration

	# 计算本帧要用的速率 rate
	var rate: float
	if direction == 0.0:
		# 无输入 → 普通减速
		rate = decel
	elif velocity.x != 0.0 and signf(direction) != signf(velocity.x):
		# 有输入，且方向与当前速度相反 → 掉头，用更大的速率
		rate = accel * turn_around_mult
	else:
		# 同向（或静止起步）→ 普通加速
		rate = accel

	velocity.x = move_toward(velocity.x, target_speed, rate * delta)

	# —— 移动 ——
	move_and_slide()
