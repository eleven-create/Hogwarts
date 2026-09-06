# /ink — 剧情源文件目录

> 存放 Ink（`inklecat`）剧情脚本。Godot 通过 `DialogueManager` 单例加载。

## 命名约定

- **章**：`chapter_<NN>.ink`，例如 `chapter_01.ink`。
- **共享片段**（可被多个章 INCLUDE）：`snippet_<name>.ink`。
- **knot / stitch 命名**：小写 snake_case，例如 `knot great_hall_intro`。

## 与游戏交互（外部函数）

`scripts/core/dialogue_manager.gd` 暴露以下外部函数供 Ink 调用：

| Ink 调用 | 作用 |
| --- | --- |
| `get_stat(stat_id)` | 读取属性值 |
| `change_stat(stat_id, amount)` | 修改属性值 |
| `change_affection(char_id, amount)` | 改变好感度 |
| `set_flag(flag_id, value)` | 设置剧情标记 |
| `get_flag(flag_id)` | 读取剧情标记 |

## 当前内容

**暂无任何 `.ink` 文件**，等待第一章剧情设计完成后填充。

## 约定

- 所有玩家可见文本用**中文**
- 专有名词（学校名、人名、咒语名）用**占位变量**，如 `{SCHOOL_NAME}`, `{CHAR_NAME}`
- IP 专有名词严禁直接写进 `.ink`，统一在 `/localization` 中定义 key