## time_manager.gd
## 职责：日历、时间推进、课程表管理
## 依赖：DataLoader
class_name TimeManager
extends Node

## 时间槽枚举
enum TimeSlot { MORNING, AFTERNOON, EVENING, NIGHT }

## 日期结构
class GameDate:
	var year: int = 1
	var season: String = "autumn"  ## autumn / winter / spring / summer
	var day: int = 1
	var time_slot: TimeSlot = TimeSlot.MORNING
	
	func to_dict() -> Dictionary:
		return {"year": year, "season": season, "day": day, "time_slot": time_slot}
	
	static func from_dict(d: Dictionary) -> GameDate:
		var gd := GameDate.new()
		gd.year = d.get("year", 1)
		gd.season = d.get("season", "autumn")
		gd.day = d.get("day", 1)
		gd.time_slot = d.get("time_slot", TimeSlot.MORNING)
		return gd

## 当前游戏日期
var current_date: GameDate = GameDate.new()

## 每学期天数
const DAYS_PER_SEASON: int = 30
const SEASONS: Array[String] = ["autumn", "winter", "spring", "summer"]

## 信号
signal time_changed(date: GameDate)
signal day_changed(day: int)
signal new_year_started(year: int)
signal season_changed(season: String)
signal time_slot_changed(slot: TimeSlot)

func _ready() -> void:
	print("[TimeManager] 就绪")

## ---- 时间推进 ----

func advance_time_slot() -> void:
	var slots := TimeSlot.values()
	var idx: int = slots.find(current_date.time_slot)
	idx += 1
	if idx >= slots.size():
		idx = 0
		advance_day()
	current_date.time_slot = slots[idx]
	time_slot_changed.emit(current_date.time_slot)
	time_changed.emit(current_date)

func advance_day() -> void:
	current_date.day += 1
	day_changed.emit(current_date.day)
	if current_date.day > DAYS_PER_SEASON:
		current_date.day = 1
		advance_season()
	time_changed.emit(current_date)

func advance_season() -> void:
	var idx: int = SEASONS.find(current_date.season)
	idx = (idx + 1) % SEASONS.size()
	var new_season: String = SEASONS[idx]
	if new_season == "autumn":
		current_date.year += 1
		new_year_started.emit(current_date.year)
	current_date.season = new_season
	season_changed.emit(new_season)
	time_changed.emit(current_date)

## ---- 课程表查询（待扩展）----

func get_current_time_slot_name() -> String:
	match current_date.time_slot:
		TimeSlot.MORNING:   return "morning"
		TimeSlot.AFTERNOON: return "afternoon"
		TimeSlot.EVENING:   return "evening"
		TimeSlot.NIGHT:     return "night"
	return "unknown"

func get_schedule_for_slot(slot: TimeSlot) -> String:
	## TODO: 从 schedule 配置表查询
	return ""

## ---- 存档兼容 ----

func set_date(d: GameDate) -> void:
	current_date = d
	time_changed.emit(current_date)

func get_date() -> GameDate:
	return current_date
