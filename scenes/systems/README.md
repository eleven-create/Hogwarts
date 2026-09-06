# /scenes/systems — 系统场景

> 纯逻辑系统（Inventory / Dialogue / SaveLoad / InkRunner 等），通常以「单节点 + 脚本」形式存在，
> 可被其他场景 `instantiate()` 后挂载。

## 命名约定
- 场景文件：`sys_<系统名>.tscn`
- 对应脚本：`scripts/systems/<系统名>.gd`

## 预期系统场景

| 场景 | 功能 |
|---|---|
| `sys_inventory.tscn` | 背包系统 |
| `sys_save_load.tscn` | 存档/读档界面 |
| `sys_appearance.tscn` | 换装界面 |

**当前为空**，等待系统实现完成后填充。