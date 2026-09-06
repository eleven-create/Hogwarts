# /scenes/world — 地图场景

> 一个地点一个 `.tscn`。命名建议：`地点英文名小写 + 下划线`，例如 `great_hall.tscn`。
> 路径登记到 `data/locations.json` 的 `scene_path` 字段。

## MVP 目标地点（按优先级）

| loc_id | 场景文件 | 说明 |
|---|---|---|
| `loc_bedroom` | `bedroom.tscn` | 玩家宿舍（MVP 起始点） |
| `loc_great_hall` | `great_hall.tscn` | 大厅 |
| `loc_grounds` | `grounds.tscn` | 城堡外场地 |

**当前为空**，等待美术/关卡设计完成后填充。