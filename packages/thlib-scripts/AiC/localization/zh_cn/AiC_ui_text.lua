---=====================================
---THLoOP Localization Dialog
---东方梦摇篮本土化 对话
---=====================================

--[=[
For translaters:
This is the UI text file of THLoOP.
It includes all text in UI and menus (not images).
Only the contents in `""` and `[[]]` need to be translated. Change other code can lead to error.
The code in `<>` is text effect. To change text effect, see `AiC_text_effect.lua`.
给翻译者：
这是东方梦摇篮的UI文本文件。
它包括所有UI和菜单中的文字（非图片）。
只有`""`和`[[]]`中的内容需要被翻译。更改其他代码可能引发错误。
`<>`中的代码是文字效果。要更改文字效果，参见`AiC_text_effect.lua`。
--]=]

local lib = aic.l10n.zh_cn.ui


---暂停菜单标题
---Pause menu title
lib.pause_menu_title = {
    gameover = '满身疮痍',
    missionincompelete = '攻略失败',
    pausemenu = '少女小憩中',
    repalyover = '回忆结束'
}

---暂停菜单选项
---Pause menu text
lib.pause_menu_text = {
    Continue = '继续挑战',
    ['Give up and Retry'] = '重新开始',
    Manual = '操作说明',
    No = '算了',
    Option = '系统设定',
    ['Quit and Save Replay'] = '保存回放后结束游戏',
    Really = '真的要这样吗？',
    ['Replay Again'] = '再次播放录像',
    ['Return to Game'] = '继续游戏',
    ['Return to Title'] = '返回标题菜单',
    ['Return to Waypoint'] = '刚才的事就当作没发生',
    ['Save Replay'] = '保存回放',
    Yes = '好的'
}

---请注意Manual中的换行均是经过规划的，翻译时请尽量保留
---Manual文本
---Manual text
lib.manual_text = {
    {
        '1.游戏的进行方式',
        '2.故事（第一章）',
        '3.操作方法',
        '4.道具',
    },
    {
        [[
            这是个要不断回避敌人的弹幕，同时将敌人击破的游戏。
            在关卡的最后设有一个B0SS，将其搞定就可以过关。

            就这样。哇真的好简单啊。
        ]],
        [[
            「——梅莉，就是这里了吧，这座塔的底下。」

            「这次在地下呢，我能感受到，这里拥有与我们所在之地类似的存在……」

            为了纪念载人深空探索的成功，科学的成功，学校内的一角建起了一座纪念塔，如发射向天上的DNA双螺旋。

            「……虽然这座星塔指向的是天上。」

            梅莉能够感觉到，通过「裂隙」观测到不同于此世的存在，十万个异想天开的、不被常识束缚的世界曾经在原子、在夸克的间隙滑过、进入梦境。

            但是，这次的存在却不一样。

            通过「星塔」的连接，看到的不是妖怪，不是复古而奇异的巨构、自然而原始的风景，而是她们所在的世界……

            更确切地说，是很久以前，被称为「现代」的世纪，但是又有什么不对。

            「这一次，可能是你的理论正确了呢。」

            莲子仍在心不在焉地看着星塔周围，思绪好似已经发射进了深空。

            梅莉继续在周围寻找。很快，她在塔底的一块地毯下找到了一个活版门。深吸一口气后，她拉着莲子跳了进去。

            「……和梅莉在一起，总是会发生这种事情呢。」
        ]],
        {
            [[
            ・上下左右
            ・SHOOT键（Z）
            ・SPELL键（X）
            ・SLOW键（Shift）
            ・PAUSE键（Esc）


            *特殊的操作
            ・高速重开
            ・截屏
            ・窗口/全屏切换
            ・回放播放加速
            ・回放播放减速
            ]],
            [[
            移动自机
            射击
            符卡攻击（有次数限制）
            低速移动
            暂停



            暂停界面按RETRY键（R）
            SNAPSHOT键（Home）
            Alt+Enter键（不可修改）
            REPFAST键（Ctrl）
            REPSLOW键（Shift）
            ]]
        },
        {
            [[
                Power道具

                得分道具
            ]],
            [[
                收集时增加1点Power。

                收集时增加大量分数。
                在画面越上方的位置取得分数越高。
            ]],
            '*以上道具在自机移动到画面上分时会自动回收'
        },
    }
}

---音乐室文本
---Music room text
lib.music_room_text = {
    title = {
        '不知名的星塔 ~ Mysterious Tower',
        '通向幻想的信道',
        '直面内心的战斗~ Interviewing Battle',
        '回忆北邮',
    },
    comment = {
        [[
            　原曲：传邮万里、上海アリス幻樂団 - レトロスペクティブ京都、
            　天狗の手帖　～ Mysterious Note
            　标题画面的的主题曲。

            　天高云淡任鸟飞，秘封来到北邮了。
            　两人小组尝试对周围一切保持着好奇，单单只剩下疲劳感，
            　这也许是一次普通的社会实践。
            　寂静的校园，无人的角落里，她们可能会做出更有趣的事情呢。
            　还是看看远方的***吧家人们。

        ]],
        [[
            原曲：上海アリス幻樂団 - 東の国の眠らない夜

            　道中的主题曲。

            　尝试着做出“寝室楼已经关门两分钟”的感觉。
            　富有冒险精神的少女们进入了塔下未知的洞穴，
            　不顾一切地向前奔跑，这是最终boss设下的陷阱吗？
            　要提醒她们一句：在隧道里乐跑，可能会被吞里程哦。
        ]],
        [[
            原曲：上海アリス幻樂団 - 風神少女、妖怪の山　～ Mysterious Mountain、
            夜のデンデラ野を逝く、少女秘封倶楽部、科学世紀の少年少女、
            月面ツアーへようこそ、ヒロシゲ36号　～ Neo Super-Express、
            最も澄みわたる空と海、未知の花 魅知の旅、天鳥船神社等

            　Boss的主题曲。

            　试图配合弹幕，用音乐展现采访的成果。
            　记者的分身正在贪婪地读取秘封少女的记忆。看来要尽快将ta打倒了呢。
        ]],
        [[
            　原曲：传邮万里、上海アリス幻樂団 - レトロスペクティブ京都
            　staff的的主题曲。

            　少女们还沉浸在旅途的喜悦中，但是有些人要考虑的就多了（笑）。
            　也许五年后、十年后回味这次旅行，她们会有不一样的感触。
        ]],
    },
    warn1 =
    [[
        ＊＊　选择的音乐尚未在游戏进行的过程中播放过　＊＊

        　　　　　　音乐的评论可能会造成剧透，
        　　　　　　　即使那样也要播放吗？
    
        　　　　想现在播放的话，请再次按下确定键。
        不想现在播放的话，请选择其它已开启的音乐进行欣赏。
    ]]
}

---完整版符卡名称
lib.sc_list = {
    '旧约「以酒还酒」', '广重「卯酉之道，心之旅」', '鸟船「奇美拉摄影展」', '莲台野「墓碑后的冥界」', '伊奘诺「神秘的具象」'
}


lib.player_scname = {
    Hiffu = { '以太「量子隧穿」', '境界「另一侧的月」' }
}

---英文的名字请不要翻译
---请保证`[[]]`内的文本不要超过四行
lib.player_select = {
    { 'Hifuu Club', '秘封组',
        '',
        {
            '高速符卡：以太「量子隧穿」',
            '低速符卡：境界「另一侧的月」',
        },
        {
            [[

            ]],
            [[

            ]]
        }
    }
}

lib.tips = {
    select = '选择',
    back = '返回上一级菜单',
    select_diff = '选择难度',
    select_player = '选择自机',
    start_game = '开始游戏',
    play_music = '播放音乐',
    pause_continue_music = '暂停/继续音乐',
    select_music = '选择音乐',
    input_char = '输入字符',
    delete_char = '删除字符',
    select_option = '选择设置项',
    change_option = '更改设置项',
    change_key_binding = '更改键位',
    select_key_binding = '选择键位',
    play_replay = '播放回放',
    select_stage = '选择关卡',
    select_save_pos = '选择保存位置',
    cancel_save_rep = '取消保存回放',
    move = '移动',
    page_up_down = '翻页',
}

lib.player_data = {
    total_play_times = '总游戏次数',
    play_time = '游玩时长',
    finish_times = '通关次数',
}

lib.music_room = {
    curr_play_pos = '当前播放位置：'
}

lib.achievement = {
    achivement_complished = "完成成就"
}

lib.option = {
    username = '用户名',
    locale = '语言　Language',
    resolution = '分辨率',
    display_mode = '显示模式',
    fullscreen_mode = '全屏模式', 
    windowed_mode = '窗口模式',
    vsync = '垂直同步',
    SFX = '音效音量',
    BGM = '背景音乐音量',
    autofire = '自动射击',
    autoslow = '自动低速',
    autododge = '双击闪避（未实装）',
    opening_se = '进入关卡时音效',
    old_version = '旧版',
    new_version = '新版',
    title_bgm = '标题画面背景音乐',
    normal_version = '普通版',
    full_version = '完全版',
    sfwmode = '健全模式', 
    supersafe = '开（超健全）',
    key_binding = '键位设置',
    reset = '重置为默认设置',
    save_and_quit = '保存并退出',
    return_to_option = '返回设置',
    choose_key_binding = '选择需要更改的键位。',
    input_new_key_binding = '按下新的键位。',
    return_to_option_and_save = '返回设置。\n键位设置将在设置保存的同时变更。',
    sfwmode_warning = '\n未满18岁或正在录像的玩家\n请务必选择健全模式为开。',
    recommend = '（推荐）',
    text2 = {
        '更改用户名。\n按Backspace键删除已输入字符，\n按Esc键保存更改。\n用户名与游戏存档绑定，\n更改用户名可以更换存档\n（需重启游戏）。',
        '更改语言设定。\n更改語言設定。\nChoose your display language.\n言語設定を変更します。\n对语言的改变将会立即生效。',
        '设置窗口显示模式下\n游戏窗口的大小。',
        '设置游戏的显示模式。',
        '启用垂直同步（VSync）\n可避免画面撕裂。',
        '设置音效的音量。',
        '设置背景音乐的音量。',
        '设置是否启用自动射击。\n若启用，需按住射击键以停火。\n不建议与自动低速一起使用。',
        '设置是否启用自动低速。\n若启用，在开火时\n将自动进入低速模式。\n不建议与自动射击一起使用。',
        '设置是否启用双击闪避（实验性）。\n若启用，双击方向键即可闪避。\n目前本功能尚处于测试阶段，\n若发生报错请报告作者。',
        '设置进入关卡时播放的音效。\n旧版为0.24a之前的音效，\n新版为0.24a之后的音效。',
        '设置标题画面的背景音乐。\n普通版为原作游戏的版本，\n完全版在普通版的基础上\n增加了一段额外旋律。',
        '设置是否显示性方面的描写。\n\n\n当然在这里你是没法关掉它的……',
        '更改键盘或手柄的按键。',
        '将所有设定还原至默认值。',
        '保存设定并退出。\n若不想保存设定，\n请直接按取消键退出。',
    },
    ---注意：大写英文字母部分不用翻译
    text3 = { { 'UP', '上移' }, { 'DOWN', '下移' }, { 'LEFT', '左移' }, { 'RIGHT', '右移' }, { 'SLOW', '低速移动' },
        { 'SHOOT', '射击/确认' }, { 'SPELL', '符卡/取消' }, { 'SPECIAL', '系统特殊功能' }, { 'REPFAST', '回放播放加速' },
        { 'REPSLOW', '回放播放减速' }, { 'MENU', '暂停/返回' }, { 'SNAPSHOT', '截图' }, { 'RETRY', '快速重新开始' } }
}

lib.replay = {
    warning = '该Replay游戏版本与当前版本相差较大，播放可能导致错误。是否继续播放？\n若要播放，请再次按下确认键。',
}

lib.save_replay = {
    warn1 = 'Replay尚未保存。是否退出？\n若要退出，请按下确认键。',
    warn2 = '该位置已有Replay。是否覆盖？\n若要覆盖，请再次按下确认键。',
}
