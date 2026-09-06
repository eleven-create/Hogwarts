# HarryPotter — 项目策划文档 v1.0

> 本文件是整个项目的「使用与设计说明书 + 策划文档」。
> 任何想了解 **这个仓库是什么 / 怎么改 / 改哪里** 的人，先读这一份就够了。
> 本文件可直接喂给其他 AI 模型作为上下文。

---

## 0. 项目速览

| 项目 | 内容 |
|---|---|
| 项目代号 | Hogwarts Life（内部名） |
| 类型 | 像素风 2D 学院生活模拟 + 分支叙事 + 数值养成 |
| 引擎 | Godot 4.x |
| 语言 | GDScript（静态类型写法） |
| 叙事 | Ink（`inklecat`） |
| 目标平台 | PC（Windows/Mac/Linux），发布 itch.io |
| 团队 | 1 人 |
| 版权定位 | 非商业同人。所有 IP 相关名词通过配置文件抽象，为换皮预留接口 |

---

## 1. 核心设计支柱

1. **忠于原著的世界观与氛围**
2. **自由**：外观、发展路线、人设、剧情选择皆可自定义
3. **数值驱动人生**（参考人生模拟器）
4. **日常玩法参考星露谷**（时间循环 + 社交 + 采集 + 探索）
5. **全角色可攻略**（长期目标，MVP 先做 3 人）

---

## 2. 版权抽象规则

> 所有涉及 IP 的文本、名称、地名、咒语名，**禁止硬编码**，一律走本地化/配置表。

- 角色名 → `characters.json` 的 `display_name_key` 字段
- 地名 → `locations.json` 的 `name_key` 字段
- 咒语/物品 → `items.json` / `spells.json`
- 显示文本 → 全部走 i18n key

**换皮时只需替换配置文件与美术资源，代码零改动。**

---

## 3. 核心循环

```
起床 → 结算精力/属性 → 查看课程表
  → [上午] 上课（选择/小游戏）→ 获得属性经验
  → [下午] 自由活动（社交/探索/采集/学习/任务）
  → [晚上] 自由活动 / 触发剧情事件
  → 睡觉 → 日历+1 → 检查触发事件
```

---

## 4. 系统清单与优先级

### P0（MVP 必做）
- S1 时间与日历系统
- S2 属性系统
- S3 对话与选择系统（接 Ink）
- S4 关系/好感系统
- S5 角色外观/换装系统
- S6 存档系统
- S7 玩家移动与场景交互

### P1（第二版）
- S8 课程小游戏
- S9 任务/事件系统扩展
- S10 物品/背包系统
- S11 采集/制作（星露谷式）

### P2（远期）
- S12 开放地图扩展
- S13 战斗/决斗系统
- S14 全员可攻略扩展
- S15 多结局系统

---

## 5. 属性系统设计（S2）

### 主属性（长期成长，通过经验值累积升级）

| ID | 名称 | 影响 |
|---|---|---|
| `intelligence` | 智力 | 学业课程、解谜、部分对话选项 |
| `charm` | 魅力 | 社交、好感获取速度、特殊对话 |
| `courage` | 勇气 | 冒险事件、决斗、部分剧情分支 |
| `cunning` | 狡黠 | 计谋类选项、隐藏路线 |
| `magic_power` | 魔力 | 咒语强度、魔法课程 |
| `constitution` | 体质 | 精力上限、体力活动 |

### 状态值（短期波动）

| ID | 名称 | 说明 |
|---|---|---|
| `energy` | 精力 | 每日行动消耗，睡觉恢复 |
| `mood` | 心情 | 影响属性获取效率 |
| `money` | 金币 | 经济系统 |
| `reputation` | 声望 | 全局评价 |

### 数值范围规范

- 主属性：0–100，通过经验值累积升级（避免直接加点，更有养成感）
- 状态值：`energy` 0–100，`mood` -50~+50，`money`/`reputation` 无上限

---

## 6. 数据结构定义

### 6.1 角色 characters.json

```json
{
  "char_id": "char_001",
  "display_name_key": "name_char_001",
  "house": "house_a",
  "gender": "female",
  "portrait_set": "portraits/char_001",
  "romanceable": true,
  "affection": 0,
  "affection_max": 100,
  "personality_tags": ["brave", "loyal"],
  "schedule_id": "sched_student_default",
  "unlock_condition": null
}
```

### 6.2 事件 events.json

```json
{
  "event_id": "evt_001",
  "title_key": "evt_001_title",
  "trigger": {
    "date": null,
    "location": "loc_great_hall",
    "conditions": [
      {"stat": "intelligence", "op": ">=", "value": 30},
      {"flag": "met_char_001", "value": true}
    ]
  },
  "ink_knot": "event_001",
  "repeatable": false,
  "priority": 10
}
```

### 6.3 对话（用 Ink 管理）

- 每个事件对应一个 Ink knot
- Ink 通过外部变量读写游戏 stats：

| Ink 调用 | 作用 |
|---|---|
| `get_stat(stat_id)` | 读取属性值 |
| `change_stat(stat_id, amount)` | 修改属性值 |
| `change_affection(char_id, amount)` | 改变好感度 |
| `set_flag(flag_id, value)` | 设置剧情标记 |

### 6.4 换装外观规范（S5）

分层立绘/精灵，图层从下到上：
```
body(体型/肤色) → hair → eyes → uniform(校服/院徽) → robe(外袍) → accessory(饰品) → wand(法杖)
```

- 每层为独立 PNG，同尺寸同锚点
- 命名：`layer_type/variant_id.png`
- 配置：`appearance.json` 记录玩家选择的各层 variant_id

### 6.5 存档 save.json

```json
{
  "version": 1,
  "date": {"year": 1, "season": "autumn", "day": 5},
  "time_slot": "afternoon",
  "player": {
    "appearance": {...},
    "stats": {...},
    "inventory": [...]
  },
  "affections": {"char_001": 25},
  "flags": {"met_char_001": true, "evt_001_done": true},
  "ink_state": "<ink序列化字符串>"
}
```

---

## 7. 项目目录结构

```
/project
├── DESIGN.md              # 本文档
├── AI_GUIDE.md            # AI 施工规范提示词模板（每次派活时用）
├── /data                  # 所有配置表（可换皮）
│   ├── characters.json    # 角色定义
│   ├── events.json        # 事件定义
│   ├── locations.json     # 地点定义
│   ├── items.json         # 物品/道具定义
│   ├── appearance.json    # 换装配置
│   └── stats_def.json     # 数值系统定义
├── /ink                   # Ink 剧情源文件
├── /scenes                # Godot 场景文件
│   ├── /world             # 地图场景
│   ├── /ui                # 界面
│   └── /systems           # 系统场景
├── /scripts               # GDScript
│   ├── /core              # 单例/管理器（Autoload）
│   │   ├── data_loader.gd
│   │   ├── game_manager.gd
│   │   ├── time_manager.gd
│   │   ├── stats_manager.gd
│   │   ├── relation_manager.gd
│   │   ├── flag_manager.gd
│   │   ├── event_manager.gd
│   │   ├── dialogue_manager.gd
│   │   └── save_manager.gd
│   ├── /systems           # 游戏系统实现
│   └── /ui                # UI 脚本
├── /assets
│   ├── /sprites           # 2D 精灵
│   ├── /portraits         # 分层立绘
│   ├── /tilesets          # 地图瓦片
│   ├── /audio             # 音效 & BGM
│   └── /fonts             # 字体
└── /localization          # i18n 文本表
    ├── zh_CN.json          # 中文
    └── en_US.json         # 英文（预留）
```

---

## 8. 核心单例（Autoload）规范

| 单例名 | 职责 |
|---|---|
| `DataLoader` | 启动时加载 /data 下所有 JSON |
| `GameManager` | 全局状态、场景切换 |
| `TimeManager` | 日历、时间推进、课程表 |
| `StatsManager` | 玩家属性读写、经验升级 |
| `RelationManager` | 好感度管理 |
| `FlagManager` | 剧情 flag 存储 |
| `EventManager` | 事件触发判定 |
| `DialogueManager` | Ink 桥接 |
| `SaveManager` | 存读档 |

---

## 9. 代码规范

### 命名约定
- 类名：`PascalCase`（如 `GameManager`）
- 函数/变量：`snake_case`（如 `get_stat_value`）
- 常量：`UPPER_CASE`（如 `MAX_AFFECTION`）
- 私有成员：前缀 `_`（如 `_cached_data`）

### 架构铁律
1. **数据驱动**：任何游戏内容（角色/事件/物品/数值/文本）必须放入 /data 的 JSON 或 /localization，禁止硬编码进脚本。
2. **IP 抽象**：禁止在代码中出现任何哈利波特专有名词（人名/地名/咒语）。一律用 id + 本地化 key。
3. **单例通信**：跨系统交互只能通过 Autoload 单例，禁止节点间直接强耦合。
4. **目录规范**：文件必须放入本规范规定的目录，命名用 snake_case。
5. **信号优先**：系统对外状态变化用 `signal` 广播，禁止让 UI 反向轮询系统内部状态。

### Godot 规范
- 使用 Godot 4.x API，禁止 Godot 3.x 旧 API
- 变量与函数必须标注类型
- 每个脚本顶部写 `class_name` 和一句注释说明职责
- 公开函数必须写简短文档注释
- 优先用 `@export` 暴露可配置项

---

## 10. MVP 范围锁定

> MVP = 一个学期的垂直切片

- **场景**：3 个（宿舍、大厅、1 个户外区）
- **可攻略角色**：3 人
- **属性**：全部 6 主属性 + 状态值
- **剧情**：1 条主线 + 每角色 2 个好感事件
- **课程**：2 门（各 1 个小游戏占位）
- **时长**：可玩通 30 游戏内天

**MVP 明确不做**：开放地图、战斗、制作系统、多结局。

---

## 11. 开发里程碑

| 里程碑 | 内容 | 周期 |
|---|---|---|
| M0 | 学习 + 骨架：Godot 基础、目录、Git、单例空壳 | 2周 |
| M1 | 核心循环：TimeManager + 移动 + 属性面板（占位美术） | 6周 |
| M2 | 叙事：Ink 接入 + 事件系统 + 好感 | 6周 |
| M3 | 换装 + 存档：S5 + S6 | 4周 |
| M4 | 内容填充：3 角色剧情、2 课程、美术替换 | 6周 |
| M5 | 打磨 + 试玩发布：音效、平衡、itch.io demo | 4周 |

---

## 12. 一人团队工作原则

1. 占位符优先：色块跑通逻辑再美化
2. 数据驱动：内容进配置表，不进代码
3. 每功能问"能否砍/能否简化"
4. 每个里程碑必须产出"可运行"版本
5. Git 每日提交，每里程碑打 tag

---

## 13. 当前进度

### ✅ M0 骨架阶段（已完成）

- ✅ Git 仓库初始化（首个 commit: `baff9a7`）
- ✅ `project.godot` 已创建（Godot 4.x，1280×720）
- ✅ 9 个 Autoload 单例已配置（DataLoader/GameManager/TimeManager/StatsManager/RelationManager/FlagManager/EventManager/DialogueManager/SaveManager）
- ✅ `.gitignore` 已配置
- ✅ 主菜单场景 `scenes/ui/ui_main_menu.tscn` + 脚本已就绪
- ✅ 所有脚本使用静态类型写法

### 🚧 M1 核心循环（进行中）

完成情况：

1. ✅ `data/characters.json` 真实数据 — 3 个可攻略角色（赫敏/德拉科/纳威）
2. ✅ `data/locations.json` 真实数据 — 4 个场景（宿舍/大礼堂/场地/走廊）
3. ✅ `data/events.json` 真实数据 — 5 个初始事件（含主线+好感事件）
4. ✅ `data/houses.json` 四大学院定义
5. ✅ `localization/zh_CN.json` 完整 IP 名词（霍格沃茨人物/地点/物品/学院）
6. ✅ `scripts/ui/ui_stats_panel.{tscn,gd}` 属性面板 UI（监听 StatsManager 信号）
7. ✅ `scripts/ui/ui_time_indicator.{tscn,gd}` 时间指示器（监听 TimeManager 信号）
8. ✅ `scripts/systems/player_movement.gd` 玩家移动系统（输入 + 出口检测）
9. ✅ `scenes/world/bedroom.tscn` 宿舍场景（MVP 第一个可探索地点）

### 🎯 后续 M1 待办：

- [ ] `scenes/world/great_hall.tscn` 大礼堂场景
- [ ] `scenes/world/grounds.tscn` 户外场地
- [ ] `scenes/world/corridor.tscn` 走廊
- [ ] `data/items.json` 物品配置（基础道具：魔杖/隐形衣/分院帽/魔法石）
- [ ] Ink 第一章剧情（占位脚本 + EXTERNAL 函数注册）
- [ ] DialogueManager 接入 Ink 运行时（依赖 Godot Ink 插件）

---

## 14. 后续改进点

> 每完成一个里程碑后回填这里。