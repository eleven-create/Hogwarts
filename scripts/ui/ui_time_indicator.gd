## ui_time_indicator.gd
## 职责：时间/日期指示器 — 显示当前季节、第几天、时间段，监听 TimeManager 信号刷新
## 依赖：TimeManager
extends PanelContainer

@onready var date_label: Label = $MarginContainer/HBoxContainer/DateLabel
@onready var time_label: Label = $MarginContainer/HBoxContainer/TimeLabel

func _ready() -> void:
	# 连接 TimeManager 信号
	TimeManager.time_changed.connect(_on_time_changed)
	_refresh_all()

## 刷新全部显示
func _refresh_all() -> void:
	var d: TimeManager.GameDate = TimeManager.get_date()
	date_label.text = "%s 第%d天" % [_get_season_name(d.season), d.day]
	time_label.text = _get_time_slot_name(d.time_slot)

## 时间变化回调
func _on_time_changed(_date: TimeManager.GameDate) -> void:
	_refresh_all()

## 获取季节中文名
func _get_season_name(season: String) -> String:
	match season:
		"autumn": return "秋季"
		"winter": return "冬季"
		"spring": return "春季"
		"summer": return "夏季"
	return season

## 获取时间段中文名
func _get_time_slot_name(slot: TimeManager.TimeSlot) -> String:
	match slot:
		TimeManager.TimeSlot.MORNING:   return "上午"
		TimeManager.TimeSlot.AFTERNOON: return "下午"
		TimeManager.TimeSlot.EVENING:   return "傍晚"
		TimeManager.TimeSlot.NIGHT:     return "夜晚"
	return "?"
