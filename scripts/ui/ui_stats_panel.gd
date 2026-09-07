## ui_stats_panel.gd
## 职责：属性面板 — 显示6主属性进度条 + 状态值，监听 StatsManager 信号刷新
## 依赖：StatsManager
extends PanelContainer

## 属性 ID -> ProgressBar 映射
const MAIN_STAT_IDS: Array[String] = [
	"intelligence", "charm", "courage",
	"cunning", "magic_power", "constitution"
]

@onready var progress_bars: Dictionary = {
	"intelligence":  $MarginContainer/VBoxContainer/GridContainer/ProgressBarINT,
	"charm":        $MarginContainer/VBoxContainer/GridContainer/ProgressBarCHA,
	"courage":      $MarginContainer/VBoxContainer/GridContainer/ProgressBarCOU,
	"cunning":      $MarginContainer/VBoxContainer/GridContainer/ProgressBarCUN,
	"magic_power":  $MarginContainer/VBoxContainer/GridContainer/ProgressBarMAG,
	"constitution": $MarginContainer/VBoxContainer/GridContainer/ProgressBarCON,
}

@onready var energy_label: Label = $MarginContainer/VBoxContainer/HBoxEnergy/ValueEnergy
@onready var mood_label: Label = $MarginContainer/VBoxContainer/HBoxMood/ValueMood

func _ready() -> void:
	# 连接信号：属性变化时刷新对应进度条
	StatsManager.stat_changed.connect(_on_stat_changed)
	_refresh_all()

## 刷新所有属性显示
func _refresh_all() -> void:
	for stat_id: String in MAIN_STAT_IDS:
		_update_stat_bar(stat_id)
	_update_energy_mood()

## 更新单个属性进度条
func _update_stat_bar(stat_id: String) -> void:
	if not progress_bars.has(stat_id):
		return
	var bar: ProgressBar = progress_bars[stat_id]
	var value: float = StatsManager.get_stat(stat_id)
	bar.value = value

## 更新精力和心情
func _update_energy_mood() -> void:
	var energy: float = StatsManager.get_stat("energy")
	var energy_max: float = StatsManager.get_stat_max("energy")
	energy_label.text = "%d/%d" % [int(energy), int(energy_max)]
	
	var mood: float = StatsManager.get_stat("mood")
	mood_label.text = "%+d" % [int(mood)]

## 信号回调：某个属性变化时
func _on_stat_changed(stat_id: String, _old_value: float, _new_value: float) -> void:
	if stat_id in MAIN_STAT_IDS:
		_update_stat_bar(stat_id)
	elif stat_id in ["energy", "mood"]:
		_update_energy_mood()
