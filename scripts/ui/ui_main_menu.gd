## ui_main_menu.gd
## 职责：主菜单界面 — 新游戏/继续/退出
## 依赖：GameManager, SaveManager
extends Control

@onready var new_game_button: Button = $VBoxContainer/NewGameButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
	# 检查是否有存档，控制"继续"按钮可用性
	continue_button.disabled = not SaveManager.has_save(0)
	print("[UIMainMenu] 就绪")

## 新游戏
func _on_new_game_pressed() -> void:
	print("[UIMainMenu] 启动新游戏")
	GameManager.start_new_game()

## 继续游戏
func _on_continue_pressed() -> void:
	print("[UIMainMenu] 继续游戏")
	if SaveManager.load_game(0):
		GameManager.continue_game()

## 退出游戏
func _on_quit_pressed() -> void:
	print("[UIMainMenu] 退出游戏")
	GameManager.quit_game()
