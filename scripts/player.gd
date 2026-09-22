extends CharacterBody2D

## 玩家移动速度
@export var player_speed: float = 300.0

## 期望的跳跃高度（单位：像素）
@export var jump_height: float = 100.0

## 上升段耗时（单位：秒）；数值越小，上升到预期高度越快
@export var time_to_peak: float = 0.33
## 下降重力倍率（下降速度通常比上升更快，手感更干脆）
@export var fall_gravity_mult: float = 1.6

## 限制最大下落速度（此为下落速度极值，通常不需要调整）
@export var max_fall_speed: float = 900.0

# 由上面参数自动算出，不需要手填
var jump_velocity: float = 0.0
var gravity_up: float = 0.0
var gravity_down: float = 0.0

func _ready() -> void:
	jump_velocity = -2.0 * jump_height / time_to_peak
	gravity_up    =  2.0 * jump_height / (time_to_peak * time_to_peak)
	gravity_down  =  gravity_up * fall_gravity_mult

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		if velocity.y < 0.0:
			velocity.y += gravity_up * delta
		else:
			velocity.y += gravity_down * delta
		velocity.y = min(velocity.y, max_fall_speed)
	else:
		velocity.y = move_toward(velocity.y, 0.0, gravity_down * delta)

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * player_speed
	else:
		velocity.x = move_toward(velocity.x, 0, player_speed)

	move_and_slide()
