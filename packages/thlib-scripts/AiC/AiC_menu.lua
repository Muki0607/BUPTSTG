---=====================================
---THLoOP Menu v1.04a
---东方梦摇篮菜单 v1.04a
---=====================================

---版本更新记录
---v1.00a
---初始版本
---v1.01a
---添加菜单栈系统与相关函数lib.PushMenuStack、lib.PopMenuStack
---v1.01b
---修复了创建菜单时飞入前位置错误的问题
---v1.01c
---修复了插件选择菜单无法保存的问题
---v1.02a
---增加了'name_regist', 'save_replay', 'replay'菜单
---v1.02b
---修复了插件选择菜单在插槽全部用完时光标仍能移到最后一个已装备插件右侧的问题
---v1.02c
---添加函数lib.ClearMenuStack、lib.InsertMenuStack
---v1.03a
---增加了'library', 'player_data'菜单
---v1.03b
---将所有使用GetLastKey的地方改为了aic.input.CheckLastKey，添加了对手柄的支持（应该）
---我自己的手柄只支持dinput所以没法测试xinput（
---由于是直接拿正则表达式一路刷下去的所以也波及了暂停菜单和原版菜单
---v1.03c
---将方向键的aic.input.CheckLastKey全部改为KeyIsDown，ZXC的全部改为KeyIsPressed
---暂停菜单未改动，因为暂停时不会更新KeyState
---主要问题在于CheckLastKey在面对手柄时极容易出问题
---v1.04a
---完善了option的用户名修改功能
---增加了'music_room'菜单
---为精简主文件将所有菜单分别移至单独的文件中
---v1.05a
---标题菜单重写：底层改为desk大画布，窗口作为取景框，所有菜单常驻画布上
---切换菜单由“删除并新建”改为移动取景框，只有活跃菜单响应玩家操作
---'pretitle'合并入'title'（报纸上半部分），'difficulty_select'与'player_select'
---合并为'pre_start'（报纸下半部分，固定hifuu_player与Hard难度）
---新增lib.SetActive、lib.IsActive、lib.GetMenu、lib.MoveAll等接口


---@class aic.menu @东方梦摇篮菜单
aic.menu = {}
local lib = aic.menu

---仿TH18菜单（其实差别很大）
---本菜单库纯手工制作，没有先定义菜单类，工程量极大
---不过正因如此怎么加新东西都没问题
-------------------------------------------------------------

---菜单名称
---练习模式已并入pre_start，practice菜单被弃用
local menu = { 'scene', 'title', 'pre_start', 'spell_practice', 'replay', 'music_room', 'option',
    'manual', 'name_regist', 'save_replay', 'player_data' }

------------------------------------------------------------
---屏幕坐标系与菜单坐标
---
---渲染一律在UI模式下进行，坐标系以窗口左下角为原点、向右向上为正，
---范围恒定是(0,0)到(screen.width, screen.height)。
---
---所有菜单（连同底层的desk）常驻在同一个坐标系里，各菜单在init中设置自己的基准坐标。
---切换活跃菜单时不做任何渲染上的干涉，而是把所有菜单对象与desk一起平移，
---使目标菜单进入屏幕：由title切到pre_start（它位于title正下方一个屏幕）时，
---所有对象一起上移一个屏幕。

---菜单静止位置的基准（屏幕中心）
---@return number @屏幕中心X
---@return number @屏幕中心Y
function lib.GetScreenCenter()
    return screen.width * 0.5, screen.height * 0.5
end

---一个屏幕的宽高
---@return number @屏幕宽
---@return number @屏幕高
function lib.GetScreenSize()
    return screen.width, screen.height
end

---练习模式标志
---nil为正常开始游戏，'stage'为关卡练习（并入pre_start）
---@type string|nil
local practice

---设置练习模式标志
---@param p string|nil @'stage'或nil
function lib.SetPractice(p)
    practice = p
end

---获取练习模式标志
---@return string|nil
function lib.GetPractice()
    return practice
end

---菜单栈
---里面放的是各菜单的类而非实例obj
lib.menu_stack = {}

---要存储的replay关卡表
---@type table
lib.last_replay = nil

---要存储的replay是否通关的标志
lib.last_replay_finish = false

------------------------------------------------------------

---各菜单的实例（所有菜单同时存在于屏幕上）
---只以class为键
lib.instances = {}

---注册一个菜单实例
---@param obj lstg.GameObject @菜单实例
function lib.RegistMenu(obj)
    if not obj or not obj.class then error("invalid menu") end
    lib.instances[obj.class] = obj
    return obj
end

---判断某菜单当前是否活跃
---@param m lstg.GameObject @要检查的菜单
---@return boolean
function lib.IsActive(m)
    return lstg.tmpvar.current_menu == m
end

---@alias direction string | "'up'" | "'down'" | "'left'" | "'right'" | "'none'" @移动方向

---菜单移动
---要求单位有t参数（移动时间）
---@param self lstg.GameObject @菜单
---@param dir direction[] @移动方向
function lib.Fly(self, dir)
    if not IsValid(self) then return end
    local t = self.t or 30
    --先算出总位移，再一次性移动过去。
    --原实现是每遇到一个方向就调用一次task.MoveTo，多个方向会串成多次移动，
    --若中途又有新的移动请求进来，位移会累加，导致移动量翻倍。
    local x, y = 0, 0
    for _, d in ipairs(dir) do
        if d == 'up' then
            y = y + screen.height
        elseif d == 'down' then
            y = y - screen.height
        elseif d == 'left' then
            x = x - screen.width
        elseif d == 'right' then
            x = x + screen.width
        else
            --none等其它值不产生位移
        end
    end
    if x == 0 and y == 0 then return end
    local tx, ty = self.x + x, self.y + y
    task.New(self, function()
        task.MoveTo(tx, ty, t * #dir, 2)
    end)
end

---把所有菜单与desk一起平移（切换活跃菜单时用）
---各菜单的移动是并行的，不会互相等待
---@param dir direction[] @移动方向
function lib.MoveAll(dir)
    for _, m in pairs(lib.instances) do
        if IsValid(m) then
            lib.Fly(m, dir)
            m.wait = 30
        end
    end
end

---BGM渐入
---@param bgm string BGM名
---@param t number 时间
function lib.BgmFadeIn(bgm, t)
    if not bgm then return end
    for i = 1, t do
        SetBGMVolume(bgm, i / t)
        task.Wait()
    end
end

---BGM渐出
---@param bgm string BGM名
---@param t number 时间
function lib.BgmFadeOut(bgm, t)
    if not bgm then return end
    for i = 1, t do
        SetBGMVolume(bgm, 1 - i / t)
        task.Wait()
    end
end

---向菜单栈加入一个菜单
---@param menu class @菜单类
---@param dir direction[] @新菜单相对于屏幕中央的方向
function lib.PushMenuStack(menu, dir)
    --向菜单栈加入一个菜单
    table.insert(lib.menu_stack, menu)
    --菜单移动
    --注意：必须新建表，不能就地修改传入的dir。
    --dir通常是调用方jump表中的方向数组，就地修改会把它永久反转，
    --导致再次进入同一菜单时移动方向相反。
    local move = {}
    for i, d in ipairs(dir) do
        if d == 'up' then
            move[i] = 'down'
        elseif d == 'down' then
            move[i] = 'up'
        elseif d == 'left' then
            move[i] = 'right'
        elseif d == 'right' then
            move[i] = 'left'
        else
            move[i] = 'none'
        end
    end
    lib.MoveAll(move)
    lib.last_move_dir = move
    --保证进入的菜单可见（各菜单的flyout可能把alpha渐出到0）
    local m = lib.instances[menu]
    if IsValid(m) then m.alpha = 255 end
    lstg.tmpvar.current_menu = m
end

---从菜单栈弹出一个菜单
function lib.PopMenuStack()
    ---从菜单栈弹出一个菜单
    table.remove(lib.menu_stack)
    local dir = {}
    for i, d in ipairs(lib.last_move_dir) do
        if d == 'up' then
            dir[i] = 'down'
        elseif d == 'down' then
            dir[i] = 'up'
        elseif d == 'left' then
            dir[i] = 'right'
        elseif d == 'right' then
            dir[i] = 'left'
        else
            dir[i] = 'none'
        end
    end
    --菜单移动
    lib.MoveAll(dir)
    lstg.tmpvar.current_menu = lib.instances[lib.menu_stack[#lib.menu_stack]]
end

---清空菜单栈
---@param move boolean @是否移动
function lib.ClearMenuStack(move)
    lib.menu_stack = {}
    if move then
        local m = lstg.tmpvar.current_menu
        local dx, dy = m.default_x - m.x, m.default_y - m.y
        for _, m in pairs(lib.instances) do
            if IsValid(m) then
                task.New(function()
                    task.MoveTo(m.x + dx, m.y + dy, 30, 2)
                    m.wait = 30
                end)
            end
        end
    end
end

---开始游戏，因为没有需要改的变量所以直接写死
function lib.StartGame()
    --固定使用hifuu_player与Hard难度
    scoredata.player_select = 4
    scoredata.difficulty_select = 3
    lstg.var.player_name = player_list[scoredata.player_select][2]
    lstg.var.rep_player = player_list[scoredata.player_select][3]
    New(tasker, function()
        lib.BgmFadeOut(aic.misc.GetCurrentBGM(), 59)
        if _debug.skip_loading or GetKeyState(KEY.S) then
            New(mask_fader, 'close')
            task.Wait(30)
            New(mask_fader, 'open')
        else
            New(aic.misc.loading_scene)
            task.Wait(270)
            New(mask_fader, 'open')
        end
        stage.group.Start(stage.groups.Hard)
    end)
end

---获取rep中的信息
---@param i number @rep编号
---@return table @rep信息
function lib.GetReplayData(i)
    ext.replay.RefreshReplay()
    local slot = ext.replay.GetSlot(i)
    if not slot then
        return { string.format('No.%02d', i), '--------', '----/--/-- --:--', '--------', '--------', '---', '---%' }
    end
    -- 使用第一关的时间作为录像时间
    local text, date = {}
    if slot.stages[1] then
        date = string.sub(aic.sys.GetTime(slot.stages[1].stageDate + setting.timezone * 3600), 1, -4)
    end
    -- 统计总分数
    local totalScore = 0
    local diff, stage_num = 0, 0
    local tmp
    for i, k in ipairs(slot.stages) do
        totalScore = totalScore + slot.stages[i].score
        --由于目前没有在stage上做难度差分，不能用这种方法
        --diff = string.match(k.stageName, '^.+@(.+)$')
        diff = ({ 'Hard' })[scoredata.difficulty_select]
        tmp = string.match(k.stageName, '^(.+)@.+$')
        if string.match(tmp, '%d+') == nil then
            stage_num = tmp
        else
            stage_num = 'St' .. string.match(tmp, '%d+')
        end
    end
    local delay = slot.gameExtendInfo
    if diff == 'Spell Practice' then
        diff = 'SpellPr' --符合原作
    end
    if tmp == 'Spell Practice' then
        stage_num = 'SC' --之后要换成符卡编号
    end
    if slot.group_finish == 1 then
        stage_num = 'All' --海猫的力量（无端
    end
    if date then
        text = { string.format('No.%02d', i), slot.userName, date, slot.stages[1].stagePlayer, diff, stage_num, delay }
    else
        text = { string.format('No.%02d', i), '--------', '----/--/-- --:--', '--------', '--------', '---', '---%' }
    end
    return text
end

---刷新replay
---就是把FetchReplaySlots搬过来了
function lib:FetchReplaySlots()
    local ret = {}

    for i = 0, ext.replay.GetSlotCount() do
        local text = lib.GetReplayData(i)
        --[[
                    text = string.format(REPLAY_DISPLAY_FORMAT1, i, date, slot.userName, totalScore)
                else
                    text = string.format(REPLAY_DISPLAY_FORMAT2, i, "N/A", 0)
                end
            ]]
        --table.insert(ret, text)
        ret[i] = text
    end
    self.text1 = ret
end

---获取额外rep信息
function lib:GetExtRepInfo()
    if self.slot then
        ---@class plus.ReplayManager.SaveData
        local slot = self.slot
        ---@class plus.ReplayManager.SaveData.StageData
        local st = slot.stages[1]
        if not st then
            self.text3_kt = nil
            return
        end
        local finish = { l10n.general.terms.yes, [0] = l10n.general.terms.no }
        local player = { Reimu = l10n.general.character_names.reimu, Marisa = l10n.general.character_names.marisa, Sakuya =
        l10n.general.character_names.sakuya, Muki = l10n.general.character_names.muki, Nenyuki = l10n.general
        .character_names.nenyuki }
        local difficulty = { l10n.general.difficulty.easy, l10n.general.difficulty.normal, l10n.general.difficulty.hard,
            l10n.general.difficulty.lunatic }
        local var = DeSerialize(st.stageExtendInfo)
        self.text3 = {
            --[l10n.general.rep_info.username] = slot.userName,
            [l10n.general.rep_info.is_finished] = finish[slot.group_finish],
            [l10n.general.rep_info.time] = aic.sys.GetTime(st.stageDate + setting.timezone * 3600),
            [l10n.general.rep_info.score] = st.score,
            --["随机数种子"] = st.randomSeed,
            [l10n.general.rep_info.player] = player[st.stagePlayer] or l10n.general.terms.unknown_player,
            [l10n.general.rep_info.version] = var.aic_version or l10n.general.terms.unknown_version,
            [l10n.general.rep_info.difficulty] = difficulty[var.difficulty] or l10n.general.terms.unknown_difficulty,
        }
        self.text3_kt = setvaluetable({
            l10n.general.rep_info.is_finished, l10n.general.rep_info.time, l10n.general.rep_info.score,
            l10n.general.rep_info.player, l10n.general.rep_info.version, l10n.general.rep_info.difficulty
            --"是否通关", "时间", "总分", "自机",
            --"游戏版本", "难度选择"
        }, self.text3)
    else
        self.text3_kt = nil
    end
end

---绘制键位提示
---@param keys table @键位表，按照{shoot, spell, special, slow, repfast}的顺序传入
---@param move table @移动键位表，传入时取代原移动键位表，并按表长度决定显示方式
function lib:DrawTips(keys, move)
    local text = ''
    local key = aic.input.KeyNameList()
    --移动键
    if move then
        if #move == 1 then --只有上下的情况
            for _, v in ipairs({ 'up', 'down' }) do
                text = text .. key[setting.keys[v]]
            end
            text = text .. move[1] .. ' '
        elseif #move == 2 then --上下和左右分开的情况
            for _, v in ipairs({ 'up', 'down' }) do
                text = text .. key[setting.keys[v]]
            end
            text = text .. move[1] .. ' '
            for _, v in ipairs({ 'left', 'right' }) do
                text = text .. key[setting.keys[v]]
            end
            text = text .. move[2] .. ' '
        elseif #move == 4 then --上下左右都不同的情况
            for k, v in ipairs({ 'up', 'down', 'left', 'right' }) do
                text = text .. key[setting.keys[v]] .. move[k] .. ' '
            end
        end
    else
        for _, v in ipairs({ 'up', 'down', 'left', 'right' }) do
            text = text .. key[setting.keys[v]]
        end
        text = text .. l10n.general.terms.move .. ' '
    end
    --其他操作
    for k, v in ipairs({ 'shoot', 'spell', 'special', 'slow' }) do
        if keys[k] then
            text = text .. key[setting.keys[v]] .. l10n.general.terms.key .. ' ' .. keys[k] .. ' '
        end
    end
    if keys[5] then
        text = text .. key[setting.keysys.repfast] .. l10n.general.terms.key .. ' ' .. keys[5]
    end
    --键位提示是固定在窗口右下角的全局UI，因此不随菜单坐标移动；
    --又因为它固定不动，非活跃时若也渲染会叠在别的菜单上，所以只在活跃时渲染
    if not lib.IsActive(self) then return end
    DrawText('main_font_zh_cn', text,
        screen.width, 10, 0.5, Color(self.alpha, 255, 255, 255), nil, 'right')
end

---初始化PlayerData
---@param player_name string @自机名称
function lib.InitPlayerData(player_name)
    local p = player_name
    --history原版已经记过了所以这里就不记了
    --虽然原版history真的写得超烂
    scoredata.player_data[p] = {
        played_num = 0,
        played_time = 0,
        finished_num = { 0, 0, 0, 0 },
        high_score = aic.table.Repeat({
            --机签 分数 时间 是否通关 处理落
            { '--------', 1000000, '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 900000,  '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 800000,  '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 700000,  '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 600000,  '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 500000,  '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 400000,  '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 300000,  '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 200000,  '----/--/-- --:--:--', 'Stage -', '---%' },
            { '--------', 100000,  '----/--/-- --:--:--', 'Stage -', '---%' },
        }, 4)
    }
end

--
---保存上一局游戏数据
---@param score table @分数数据表
---@return table @整理后的高分榜
---@return number @本次分数数据位置
function lib.SavePlayerData(score)
    local player_list = { "reimu_player", "marisa_player", "sakuya_player", "muki_player", "nenyuki_player" }
    local player, diff = player_list[aic.sys.GetPlayer()], aic.sys.GetDiff()
    local hscore = {}
    for i = 1, 10 do --因为scoredata有元表所以不能直接用ipairs
        hscore[i] = scoredata.player_data[player].high_score[diff][i]
    end
    local function comp(t1, t2)
        return t1[2] > t2[2]
    end
    --以本次得分是否高过高分榜最后一名决定是否更新
    if hscore[10] and comp(score, hscore[10]) then
        hscore[10] = score
    end
    --以分数整理高分榜
    table.sort(hscore, comp)
    --不要问为什么，总之只有这样写才存得进去
    local temp = aic.table.Repeat({}, 10)
    for i = 1, 10 do
        for j = 1, 5 do
            if j == 1 then
                --去除名称中多余的双引号（虽然我也不知道怎么多出来的）
                temp[i][j] = aic.string.Filter(hscore[i][j], '\"')
            elseif j == 3 then
                --去除时间中多余的空格（虽然我也不知道怎么多出来的）
                local s = aic.string.Filter(hscore[i][j], '%s')
                temp[i][j] = string.sub(s, 1, 10) .. ' ' .. string.sub(s, 11)
            else
                temp[i][j] = hscore[i][j]
            end
        end
    end
    local t = {
        temp[1],
        temp[2],
        temp[3],
        temp[4],
        temp[5],
        temp[6],
        temp[7],
        temp[8],
        temp[9],
        temp[10],
    }
    scoredata.player_data[player].high_score[diff] = t
    local pos
    --不是，这个新表应该和scoredata没有关系了啊……为什么还是不能用ipairs啊
    --[[
    for k, v in ipairs(t) do
        if v[2] == score[2] then pos = k end
    end
    --]]
    for i = 1, 10 do
        if t[i][2] == score[2] then pos = i end
    end
    pos = pos or 'XX' --打完全关之后分数低于最低分的情况
    return temp, pos
end

--]]

---获取当前rep的处理落率
---@return string 字符串格式的处理落率
function lib.GetReplayDelay()
    local sec = ((lib.last_replay_frame or 0) / 60)             --将单位转换为秒
    local ret = 1 - (sec / (lib.last_replay_time or 1))         --计算处理落率
    ret = string.format('%.1f', ret) .. '%'                     --保留一位小数
    return ret
end

---加载并创建所有菜单
---注意：不能在这里直接创建菜单对象。
---本文件是在脚本加载阶段被执行的，此时早于core.lua的GameInit，
---而各游戏对象类的回调（含init）要等到GameInit里的lstg.RegisterAllGameObjectClass()
---才会被整理给底层，在此之前New()创建的对象不会调用init。
---因此这里只加载菜单脚本，实例化交给lib.NewMenus()，由场景在进入时调用。
function lib.Initialize()
    ---加载所有菜单
    for _, m in ipairs(menu) do
        DoFile('AiC/menu/' .. m .. '.lua')
    end
end

---创建所有菜单实例（必须在类注册完成之后调用）
---已经存在的实例不会重复创建；scene自身由入口创建，这里跳过，否则会递归
function lib.NewMenus()
    for _, m in ipairs(menu) do
        if m ~= 'scene' and not IsValid(lib.instances[lib[m]]) then
            New(lib[m])
        end
    end
end

lib.Initialize()


----------------------------------------
---资源

--标题菜单

LoadImageFromFile("desk", "THlib/UI/menu/desk.png")

lib.bgw, lib.bgh = GetTextureSize("desk")

LoadImageFromFile("title", "THlib/UI/menu/title.png")

---title背景图像的原始尺寸（用于把它缩放到宽screen.width、高screen.height*2）
lib.bgtw, lib.bgth = GetTextureSize("title")

LoadImageFromFile("general_bg", "THlib/UI/menu/general_bg.png")
LoadImageFromFile("general_bg2", "THlib/UI/menu/general_bg2.png")
LoadImageFromFile("player_data", "THlib/UI/menu/player_data.png")
LoadImageFromFile("option", "THlib/UI/menu/option.png")
LoadImageFromFile("music_room", "THlib/UI/menu/music_room.png")
