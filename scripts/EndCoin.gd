extends Area2D

## 结算场景的路径（在 Inspector 里填，或写死）
@export_file("*.tscn") var result_scene_path: String = "res://scenes/Levels/MVP.tscn"

## 防止重复触发
var _triggered := false

func _ready() -> void:
	# 监听"有物体进入"信号
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	# 只对玩家生效
	if not body.is_in_group("player"):
		return

	_triggered = true
	_go_to_result()

func _go_to_result() -> void:
	if result_scene_path.is_empty():
		push_warning("Goal: result_scene_path 未设置")
		return
	get_tree().change_scene_to_file(result_scene_path)
