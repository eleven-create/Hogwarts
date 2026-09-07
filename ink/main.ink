// main.ink
// Hogwarts Life 主线剧情集合
// 每个 knot 对应 events.json 中的 ink_knot 字段
// 所有 knot 以 "===" 开头，便于 GDScript 通过 ChoosePathString(knot_name) 跳转

// === EXTERNAL 函数声明（告诉 Ink 这些函数由外部提供）===
EXTERNAL get_stat(stat)
EXTERNAL change_stat(stat, amount)
EXTERNAL change_affection(char_id, amount)
EXTERNAL set_flag(flag_id, value)
EXTERNAL get_flag(flag_id)

// === 全局变量 ===
VAR met_hermione = false
VAR met_draco = false
VAR met_harry = false

// === 全局开场（用于测试）===
=== start ===
# character: 旁白
清晨的阳光透过彩色玻璃窗洒在长桌上，礼堂里弥漫着烤面包的香气。

~ met_hermione = true

-> event_great_hall_meal

// === 礼堂用餐事件（evt_great_hall_meal）===
=== event_great_hall_meal ===
# character: 旁白
你端着餐盘走进大礼堂，几个熟悉的身影映入眼帘。

* [走向赫敏]
    -> meet_hermione
* [走向德拉科]
    -> meet_draco
* [走向哈利]
    -> meet_harry
* [找个角落安静吃早餐]
    -> eat_alone

// === 赫敏分支 ===
=== meet_hermione ===
# speaker: name_char_hermione
# portrait: portraits/char_hermione/neutral
哦，你好！我正在复习变形课的笔记，要一起看吗？

* [一起研究（智力经验 +5）]
    ~ change_stat("intelligence", 5.0)
    ~ change_affection("char_hermione", 3)
    # speaker: name_char_hermione
    # portrait: portraits/char_hermione/happy
    太棒了！你的问题问得很好，看得出你也很用功。
    -> event_finished

* [礼貌地婉拒]
    # speaker: name_char_hermione
    # portrait: portraits/char_hermione/neutral
    好的，那下次吧。
    ~ change_stat("mood", -2.0)
    -> event_finished

// === 德拉科分支 ===
=== meet_draco ===
# speaker: name_char_draco
# portrait: portraits/char_draco/smirk
哦？我还以为你不敢过来呢。

* [回敬一句（狡黠经验 +3）]
    ~ change_stat("cunning", 3.0)
    # speaker: name_char_draco
    # portrait: portraits/char_draco/raised_eyebrow
    哼，至少还有点胆量。
    ~ change_affection("char_draco", 2)
    -> event_finished

* [沉默坐下]
    # speaker: name_char_draco
    # portrait: portraits/char_draco/curious
    嗯？没什么要说的吗？
    -> event_finished

// === 哈利分支 ===
=== meet_harry ===
# speaker: name_char_harry
# portrait: portraits/char_harry/friendly
嗨！新来的吧？需要帮忙吗？

* [接受帮助（勇气经验 +3）]
    ~ change_stat("courage", 3.0)
    # speaker: name_char_harry
    # portrait: portraits/char_harry/happy
    跟我来，我知道一些有趣的秘密地点。
    ~ change_affection("char_harry", 3)
    ~ set_flag("met_harry", true)
    -> event_finished

* [独自探索]
    # speaker: name_char_harry
    # portrait: portraits/char_harry/encouraging
    没问题，我相信你能行的！
    -> event_finished

// === 独自用餐 ===
=== eat_alone ===
# character: 旁白
你一个人安静地吃完早餐，心情恢复了。
~ change_stat("mood", 5.0)
~ change_stat("energy", 10.0)
-> event_finished

// === 通用结束 ===
=== event_finished ===
# character: 旁白
早餐时间结束。
-> END

// === 宿舍晨起事件（evt_morning_wake）===
=== event_morning_wake ===
# character: 旁白
你从床上醒来，阳光透过窗帘的缝隙照进房间。

* [赖床 5 分钟（心情 +2，精力 -5）]
    ~ change_stat("mood", 2.0)
    ~ change_stat("energy", -5.0)
    # character: 旁白
    再睡一会儿吧~
    -> wake_finished

* [立即起床（精力 +10）]
    ~ change_stat("energy", 10.0)
    # character: 旁白
    今天也要精神满满！
    -> wake_finished

=== wake_finished ===
-> END
