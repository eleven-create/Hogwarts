// main.ink
// Hogwarts Life 主线剧情集合
// 每个 knot 对应 events.json 中的 ink_knot 字段
// 所有 knot 以 "===" 开头，便于 GDScript 通过 ChoosePathString(knot_name) 跳转
//
// 语法说明：
//   ~ 开头 = Ink 语句（修改变量、调用 EXTERNAL）
//   -> 开头 = 跳转（-> knot_name 跳到指定 knot，-> END 结束）
//   * [选项文字] = 对话选项，~ 开头则为 Ink 语句行

// === EXTERNAL 函数声明（告诉 Ink 这些函数由外部提供）===
EXTERNAL get_stat(stat)
EXTERNAL change_stat(stat, amount)
EXTERNAL change_affection(char_id, amount)
EXTERNAL set_flag(flag_id, value)
EXTERNAL get_flag(flag_id)
EXTERNAL advance_time(slot)
EXTERNAL add_item(item_id)

// === 全局变量 ===
VAR met_hermione = false
VAR met_draco = false
VAR met_harry = false
VAR talked_to_bed = false

// ============================================================
// 场景 1：宿舍晨起事件（bedroom 床 NPC，loc_bedroom）
// ============================================================
=== event_morning_wake ===
# character: 旁白
你从柔软的床上缓缓睁开眼睛。阳光透过厚重的窗帘缝隙，金色的光柱中漂浮着细小的尘埃，空气中弥漫着淡淡的旧书香气。

* [赖床 5 分钟]
    ~ change_stat("mood", 2.0)
    ~ change_stat("energy", -5.0)
    ~ talked_to_bed = true
    # character: 旁白
    你裹紧被子，决定再睡一会儿。
    再睡一会儿吧~ 温暖的被窝真让人舍不得离开。
    -> wake_linger

* [起床洗漱]
    ~ change_stat("energy", 5.0)
    ~ talked_to_bed = false
    # character: 旁白
    你利落地起身，简单梳洗之后，感觉神清气爽。
    -> wake_ready

=== wake_linger ===
# character: 旁白
一阵急促的敲门声打断了你的好梦。
    ~ change_stat("mood", -3.0)
    ~ change_stat("energy", 3.0)
    "喂！再不起来早餐都结束了！" 门外传来不耐烦的喊声。
    ~ talked_to_bed = true
-> wake_ready

=== wake_ready ===
# character: 旁白
今天是在霍格沃茨的第一天。
走廊尽头传来脚步声和笑声，远处隐约可见大礼堂的灯火。
    ~ change_stat("courage", 1.0)
-> morning_wake_done

=== morning_wake_done ===
# character: 旁白
新的一天正式开始。
    ~ advance_time("morning")
-> END


// ============================================================
// 场景 2：大礼堂用餐（great_hall 三个 NPC，loc_great_hall）
// 每个 NPC 独立事件入口，方便后续扩展
// ============================================================
=== event_great_hall_meal ===
# character: 旁白
你端着餐盘走进大礼堂。数百支蜡烛漂浮在高高的天花板上，四张长桌旁坐满了学生，空气中弥漫着烤面包和熏肉的香气。

* [走向赫敏]
    -> meet_hermione
* [走向德拉科]
    -> meet_draco
* [走向哈利]
    -> meet_harry
* [找个角落安静吃早餐]
    -> eat_alone

// ---- 赫敏分支 ----
=== meet_hermione ===
~ met_hermione = true
# speaker: name_char_hermione
# portrait: portraits/char_hermione/neutral
你走到格兰芬多长桌旁，赫敏正埋头看着一本厚重的书，手边放着一杯没怎么动过的南瓜汁。
她抬起头，眉毛微微一挑。

哦，你好。我是赫敏·格兰杰。你是新生？

* [自我介绍并询问她在读什么书]
    # speaker: name_char_hermione
    # portrait: portraits/char_hermione/happy
    哦，你对这个感兴趣？ 这是《霍格沃茨一段校史》，我正在查一个有趣的地方……
    ~ change_stat("intelligence", 8.0)
    ~ change_affection("char_hermione", 5)
    格兰芬多的宝藏……你听说过吗？
    -> hermione_treasure

* [友好地自我介绍]
    # speaker: name_char_hermione
    # portrait: portraits/char_hermione/neutral
    你好。我是……（你的名字）。请多关照。
    ~ change_affection("char_hermione", 2)
    赫敏微微一笑，点点头。
    嗯，很高兴认识你。有什么不懂的可以问我。
    -> hermione_talk_done

* [简单点头，坐下来吃早餐]
    ~ change_stat("energy", 5.0)
    ~ change_stat("mood", 2.0)
    # speaker: name_char_hermione
    # portrait: portraits/char_hermione/neutral
    （赫敏看了你一眼，又低头继续看书。）
    -> hermione_talk_done

=== hermione_treasure ===
# character: 旁白
赫敏翻到书的某一页，指着一段用红色墨水圈出的文字。
# speaker: name_char_hermione
据说，格兰芬多的密室入口就在……
~ set_flag("hermione_trust", true)
* [追问细节]
    ~ change_stat("intelligence", 5.0)
    ~ change_affection("char_hermione", 3)
    # speaker: name_char_hermione
    # portrait: portraits/char_hermione/happy
    好问题！我也不确定……但如果我们一起去找的话……
    赫敏的眼中闪烁着好奇的光芒。
    -> hermione_talk_done
* [觉得太冒险，委婉拒绝]
    ~ change_stat("courage", 2.0)
    # speaker: name_char_hermione
    # portrait: portraits/char_hermione/neutral
    嗯，也许你是对的。第一天就探险太冒险了。
    （赫敏合上书，若有所思。）
    -> hermione_talk_done

=== hermione_talk_done ===
~ change_stat("energy", 8.0)
# character: 旁白
你和赫敏的对话愉快地结束了。
早餐时间过得很快。
-> event_finished

// ---- 德拉科分支 ----
=== meet_draco ===
~ met_draco = true
# speaker: name_char_draco
# portrait: portraits/char_draco/smirk
德拉科斜靠在长椅上，银金色的头发一丝不苟，他漫不经心地用银刀切着熏肉。
看到你走近，他挑了挑眉。

哦？你是哪个学院的？

* [坦诚回答]
    ~ change_affection("char_draco", 1)
    ~ change_stat("charm", 3.0)
    我是……（你的名字）。还没有被分到学院。
    # speaker: name_char_draco
    # portrait: portraits/char_draco/curious
    哦？还没分院？那是麻瓜出身的？
    德拉科的语气里带着一丝好奇。
    -> draco_curious
* [反问他的学院]
    ~ change_stat("cunning", 3.0)
    ~ change_affection("char_draco", 2)
    # speaker: name_char_draco
    # portrait: portraits/char_draco/smirk
    德拉科轻笑一声，下巴微微扬起。
    我？斯莱特林，纯正的马尔福家族。
    他的眼神里带着一丝骄傲。
    -> draco_proud
* [冷淡回应后离开]
    ~ change_stat("energy", 5.0)
    # speaker: name_char_draco
    # portrait: portraits/char_draco/annoyed
    德拉科的眼神中闪过一丝不悦。
    哼，真没礼貌。
    （他继续低头切熏肉，不再理你。）
    -> event_finished

=== draco_curious ===
# speaker: name_char_draco
# portrait: portraits/char_draco/curious
麻瓜出身也没什么，能力才是最重要的。
他似乎对你产生了一点兴趣。
~ set_flag("draco_interested", true)
* [表示想和他交朋友]
    ~ change_affection("char_draco", 4)
    ~ change_stat("charm", 3.0)
    # speaker: name_char_draco
    # portrait: portraits/char_draco/raised_eyebrow
    德拉科上下打量了你一番。
    哼，有点意思。
    （他的语气虽然没有完全放开，但似乎并不排斥。）
    -> draco_talk_done
* [保持礼貌距离]
    ~ change_stat("charm", 2.0)
    # speaker: name_char_draco
    # portrait: portraits/char_draco/neutral
    嗯，有缘再见吧。
    （德拉科微微点头，举起杯子抿了一口。）
    -> draco_talk_done

=== draco_proud ===
# speaker: name_char_draco
# portrait: portraits/char_draco/smirk
斯莱特林是霍格沃茨最古老的学院之一，
我们的校友包括许多伟大的巫师。
* [表现出兴趣]
    ~ change_affection("char_draco", 3)
    ~ change_stat("cunning", 3.0)
    # speaker: name_char_draco
    # portrait: portraits/char_draco/raised_eyebrow
    哼，算你有眼光。
    （德拉科的表情稍微缓和了一些。）
    ~ set_flag("draco_interested", true)
    -> draco_talk_done
* [礼貌但保持距离]
    ~ change_stat("energy", 3.0)
    # speaker: name_char_draco
    # portrait: portraits/char_draco/neutral
    了解了，谢谢分享。
    （德拉科轻哼一声，继续用餐。）
    -> draco_talk_done

=== draco_talk_done ===
~ change_stat("energy", 8.0)
# character: 旁白
德拉科似乎对你有了一些印象。
早餐时间结束。
-> event_finished

// ---- 哈利分支 ----
=== meet_harry ===
~ met_harry = true
# speaker: name_char_harry
# portrait: portraits/char_harry/friendly
哈利正坐在长桌的尽头，额头上有一道闪电形的伤疤，但他的眼神温和而友善。
看到你走过来，他露出了一个友善的微笑。

你好！我是哈利。你是新生吧？感觉怎么样？

* [热情地打招呼]
    ~ change_stat("courage", 5.0)
    ~ change_affection("char_harry", 4)
    我是……（你的名字）！你好，哈利波特！久仰大名！
    # speaker: name_char_harry
    # portrait: portraits/char_harry/happy
    哈利有些不好意思地笑了笑。
    别叫我名人啦，叫我哈利就好。
    （他的笑容很真诚，没有一点架子。）
    -> harry_befriend

* [友好地自我介绍]
    ~ change_affection("char_harry", 3)
    ~ change_stat("charm", 3.0)
    你好，哈利。我叫……（你的名字）。第一天有点紧张。
    # speaker: name_char_harry
    # portrait: portraits/char_harry/friendly
    哈哈，我第一天也很紧张。
    哈利友善地点点头。
    有什么不懂的可以问我，我在这里已经待了一段时间了。
    -> harry_befriend

* [平静地点点头，坐下来吃早餐]
    ~ change_stat("energy", 5.0)
    ~ change_stat("mood", 3.0)
    # speaker: name_char_harry
    # portrait: portraits/char_harry/friendly
    （哈利温和地微笑着，没有勉强你。）
    嗯，好好享受早餐吧。
    -> event_finished

=== harry_befriend ===
# speaker: name_char_harry
# portrait: portraits/char_harry/encouraging
对了，如果你想去图书馆的话，我可以带你认识赫敏，
她对学校了如指掌。
或者，如果你想去户外走走，黑湖边的风景很美。
~ set_flag("harry_friend", true)
~ change_stat("energy", 10.0)
~ change_stat("mood", 5.0)
# character: 旁白
你和哈利成为了朋友。
早餐时间愉快地结束了。
-> event_finished

// ---- 独自用餐 ----
=== eat_alone ===
~ change_stat("energy", 15.0)
~ change_stat("mood", 8.0)
# character: 旁白
你找了一个安静的角落，悠闲地吃完早餐。
周围的喧嚣仿佛与你无关，你享受着这份宁静。
早餐时间结束。
-> event_finished

// ---- 通用结束 ----
=== event_finished ===
# character: 旁白
早餐时间结束。
~ advance_time("late_morning")
-> END


// ============================================================
// 场景 3：赫敏图书馆约会（hermione_library，条件：intelligence >= 20）
// ============================================================
=== event_hermione_library ===
# character: 旁白
图书馆里安静得只能听到翻书的沙沙声，
高耸的书架间弥漫着古老羊皮纸的气息。
赫敏正坐在靠窗的位置，面前摊开了五六本书。

~ met_hermione = true
# speaker: name_char_hermione
# portrait: portraits/char_hermione/happy
你来了！太好了，我正需要有人帮我翻一翻这些参考资料。
来看看这个——

她指着书页上的某段文字，眼睛闪闪发亮。
~ set_flag("hermione_library_visited", true)

* [认真帮她查阅资料]
    ~ change_stat("intelligence", 10.0)
    ~ change_affection("char_hermione", 8)
    # speaker: name_char_hermione
    # portrait: portraits/char_hermione/very_happy
    哇！你找到了！我找了半天都没注意到这段……
    赫敏兴奋地拍了拍桌子。
    你真是太厉害了！
    ~ set_flag("hermione_impressed", true)
    -> hermione_lib_end

* [陪她一起研究]
    ~ change_stat("intelligence", 6.0)
    ~ change_affection("char_hermione", 5)
    # speaker: name_char_hermione
    # portrait: portraits/char_hermione/happy
    嗯，你的思路和我不太一样，但也许……
    赫敏若有所思地皱起眉头。
    等等，这样好像也说得通！
    ~ set_flag("hermione_impressed", true)
    -> hermione_lib_end

* [听她讲解，但不帮忙]
    ~ change_affection("char_hermione", 2)
    # speaker: name_char_hermione
    # portrait: portraits/char_hermione/neutral
    （她耐心地讲解着，虽然你没有参与研究，但听得很认真。）
    赫敏满意地点点头。
    嗯，听得懂就好，以后有机会一起研究。
    -> hermione_lib_end

=== hermione_lib_end ===
~ change_stat("energy", -5.0)
# character: 旁白
图书馆的时光过得很快，
赫敏合上书本，伸了个懒腰。
# speaker: name_char_hermione
# portrait: portraits/char_hermione/neutral
谢谢你陪我。今天很开心。
下次有好玩的事情记得叫我！
~ add_item("hermione_bookmark")
-> END


// ============================================================
// 场景 4：德拉科走廊邂逅（draco_corridor，条件：met_draco = true）
// ============================================================
=== event_draco_corridor ===
# character: 旁白
走廊里的烛火摇曳，墙壁上的肖像画窃窃私语。
德拉科靠在墙边，双臂抱胸，似乎在等人。

~ met_draco = true
# speaker: name_char_draco
# portrait: portraits/char_draco/neutral
……你来了。
他抬起头，银灰色的眼眸打量着你。

* [走过去打招呼]
    ~ change_affection("char_draco", 3)
    ~ change_stat("charm", 3.0)
    # speaker: name_char_draco
    # portrait: portraits/char_draco/raised_eyebrow
    哼，总算来了。
    德拉科的语气虽然冷淡，但没有恶意。
    我有件事想确认一下。
    -> draco_question

* [保持距离，观察他]
    ~ change_stat("cunning", 2.0)
    # speaker: name_char_draco
    # portrait: portraits/char_draco/curious
    德拉科注意到你的目光，轻哼一声。
    怎么，不敢过来？
    -> draco_challenge

=== draco_question ===
# speaker: name_char_draco
# portrait: portraits/char_draco/serious
今天早餐的时候，你表现得还不错。
有些人……我不喜欢。但你，似乎还不算太无聊。
* [表示感谢]
    ~ change_affection("char_draco", 5)
    ~ change_stat("charm", 5.0)
    # speaker: name_char_draco
    # portrait: portraits/char_draco/raised_eyebrow
    哼，别误会，我不是在夸你。
    （德拉科转过身，背对着你。）
    ……但也不讨厌。
    ~ set_flag("draco_acknowledged", true)
    -> draco_end

* [保持冷静，不卑不亢]
    ~ change_stat("cunning", 3.0)
    ~ change_affection("char_draco", 3)
    # speaker: name_char_draco
    # portrait: portraits/char_draco/curious
    德拉科眉毛一挑，似乎对你的反应有些意外。
    有点意思。
    -> draco_end

=== draco_challenge ===
# speaker: name_char_draco
# portrait: portraits/char_draco/smirk
怎么，怕了？
* [正面回应]
    ~ change_stat("courage", 5.0)
    ~ change_affection("char_draco", 4)
    # speaker: name_char_draco
    # portrait: portraits/char_draco/raised_eyebrow
    德拉科眼中闪过一丝赞赏。
    哼，有骨气。很久没见过这样的人了。
    ~ set_flag("draco_acknowledged", true)
    -> draco_end
* [转身离开]
    ~ change_stat("energy", 3.0)
    # speaker: name_char_draco
    # portrait: portraits/char_draco/annoyed
    （他轻哼一声，看着你离开的背影，没有再说什么。）
    -> draco_end

=== draco_end ===
~ change_stat("energy", -3.0)
~ set_flag("draco_corridor_met", true)
# character: 旁白
德拉科消失在走廊的尽头。
这次相遇让你对他有了新的认识。
-> END


// ============================================================
// 场景 5：哈利户外grounds（harry_grounds，条件：harry_friend = true）
// ============================================================
=== event_harry_grounds ===
# character: 旁白
黑湖边，清风徐来，水面波光粼粼。
远处的禁林笼罩在一层薄雾之中，给人一种神秘而庄严的感觉。
哈利正坐在湖边的一块大石头上，出神地看着湖面。

~ met_harry = true
# speaker: name_char_harry
# portrait: portraits/char_harry/thoughtful
哦，你来了。坐吧。
他拍了拍身边的位置。

* [坐到他身边]
    ~ change_affection("char_harry", 5)
    ~ change_stat("courage", 4.0)
    # speaker: name_char_harry
    # portrait: portraits/char_harry/friendly
    （你在他身边坐下，哈利递给你一块巧克力蛙。）
    谢谢你陪我。这里很安静，我经常来这里想事情。
    -> harry_talk

* [站着，问他在想什么]
    ~ change_affection("char_harry", 3)
    ~ change_stat("charm", 3.0)
    # speaker: name_char_harry
    # portrait: portraits/char_harry/slight_smile
    嗯……在想一些事情。
    哈利回头看着你，露出一个温和的微笑。
    不过有人陪着，感觉好多了。
    -> harry_talk

=== harry_talk ===
# speaker: name_char_harry
# portrait: portraits/char_harry/encouraging
你知道吗，每个人都有自己想要保护的东西。
对我来说，是我的朋友们。
哈利看着远方的城堡，眼神坚定。
~ set_flag("harry_trusts_you", true)

* [分享你的想法]
    ~ change_stat("courage", 5.0)
    ~ change_affection("char_harry", 6)
    # speaker: name_char_harry
    # portrait: portraits/char_harry/very_happy
    哈利认真听完，点点头。
    你说得对。有你在，我觉得我们能一起面对很多事。
    ~ set_flag("best_friend_harry", true)
    -> harry_end

* [安静地陪他看风景]
    ~ change_stat("mood", 8.0)
    ~ change_affection("char_harry", 4)
    # speaker: name_char_harry
    # portrait: portraits/char_harry/friendly
    （你们就这样静静地坐着，享受着湖边的宁静。）
    哈利轻轻叹了口气，笑着说：
    谢谢你来陪我。
    -> harry_end

=== harry_end ===
~ change_stat("energy", 10.0)
~ change_stat("mood", 10.0)
# character: 旁白
夕阳西下，你们一起走回城堡。
这一天，你收获了一个真正的朋友。
~ add_item("golden_snitch_photo")
-> END


// ============================================================
// 附录：游戏开始入口（调试用）
// ============================================================
=== start ===
# character: 旁白
清晨的阳光透过彩色玻璃窗洒在长桌上，礼堂里弥漫着烤面包的香气。
你端起餐盘，四处寻找座位……
~ met_hermione = true
-> event_great_hall_meal
