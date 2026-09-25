local lib = aic.menu



---记录名称（机签）
---这里参考TH18要存数据，所以先输一遍名字
---部分参考新版lstg菜单
lib.name_regist = Class(object)

function lib.name_regist:init()
    self.class = lib.name_regist
    self.num = 9 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP + self.num
    self.posX = 0
    self.posY = 0
    self.x = screen.width * 0.5
    self.y = screen.height * 0.5
    self.y = self.y + screen.height * 2
    self.default_x = self.x
    self.default_y = self.y
    self.bound = false
    self.t = 8
    self.wait = 30
    self.alpha = 255
    self.bound = false
    self.stages = lib.last_replay
    self.finish = lib.last_replay_finish
    self.lname = 8
    self.data = nil
    self.name = setting.username or ''
    self._posX = aic.sys.GetPlayer() --由于没有开始新的一局，此时可直接使用上一局选择来判断
    self._posY = aic.sys.GetDiff()
    self.player_list = { "hifuu_player" }
    self.diff_list = { "Hard" }
    self.l = 10

    lstg.tmpvar.current_menu = self

    ---获得分数数据，由FetchReplaySlots修改而来
    ---@return table @分数数据表
    function self.GetScore()
        ext.replay.RefreshReplay() --这个不能忘，否则读到的就是上次的rep了
        local slot = ext.replay.GetSlot(0)
        --所有菜单在游戏启动时就会创建，此时可能还没有任何rep，必须判空
        if not slot then
            return { '', 0, '----/--/-- --:--:--', 'Stage -', '---%' }, nil
        end
        -- 使用第一关的时间作为录像时间
        local date = '----/--/-- --:--:--'
        if slot.stages[1] then
            date = aic.sys.GetTime(slot.stages[1].stageDate + setting.timezone * 3600)
        end
        -- 统计总分数
        local totalScore = 0
        local stage_num = 0
        local tmp
        for i, k in ipairs(slot.stages) do
            totalScore = totalScore + slot.stages[i].score
            tmp = string.match(k.stageName, '^(.+)@.+$')
            if string.match(tmp, '%d+') == nil then
                stage_num = tmp
            else
                stage_num = 'Stage ' .. string.match(tmp, '%d+')
            end
        end
        if stage_num == 'AliceInCradle' then
            stage_num = 'Extra'
        end
        if slot.group_finish == 1 then
            stage_num = 'Clear'
        end
        local delay = lib.GetReplayDelay()
        return { '', totalScore, date, stage_num, delay }, slot --保存rep时会用到的当前rep
        --{ '--------', 1000000, '----/--/-- --:--:--', 'Stage -', '---%' }
    end
    
    ---更新名称
    function self.UpdateName()
        self.data[self.score_pos][1] = self.name
    end

    ---获取键盘
    ---好暴力的写法
    ---@return table
    function self.GetKeyboard()
        local _keyboard = {}
        for i = 65, 90 do
            table.insert(_keyboard, i)
        end
        for i = 97, 122 do
            table.insert(_keyboard, i)
        end
        for i = 48, 57 do
            table.insert(_keyboard, i)
        end
        for _, i in ipairs({ 43, 45, 61, 46, 44, 33, 63, 64, 58, 59, 91, 93, 40, 41, 95, 47, 123, 125, 124, 126, 94 }) do
            table.insert(_keyboard, i)
        end
        for i = 35, 38 do
            table.insert(_keyboard, i)
        end
        for _, i in ipairs({ 42, 92, 127, 34 }) do
            table.insert(_keyboard, i)
        end
        return _keyboard
    end

    function self.initialize()
        self.init_flag = true
        local score
        score, self.slot = self.GetScore()
        self.data, self.score_pos = lib.SavePlayerData(score)
        if self.score_pos == 'XX' then self.data.XX = score end
        self.UpdateName()
        _play_music('bgm0', nil, false)
    end

    self.keyboard = self.GetKeyboard()
    lib.RegistMenu(self)
end

function lib.name_regist:frame()
    task.Do(self)
    --只有活跃的菜单才响应玩家操作
    if not lib.IsActive(self) then return end
    ---初始化
    if not self.init_flag then
        self.initialize()
        self.init_flag = true
    end
    self.wait = max(self.wait - 1, 0)
    self.posX = (self.posX + 13) % 13
    self.posY = (self.posY + 7) % 7
    if self.wait < 1 then
        --local lastkey = GetLastKey()
        if KeyIsDown('up') then
            self.wait = self.t
            self.posY = self.posY - 1
            PlaySound('select00', 0.3)
        elseif KeyIsDown('down') then
            self.wait = self.t
            self.posY = self.posY + 1
            PlaySound('select00', 0.3)
        elseif KeyIsDown('left') then
            self.wait = self.t
            self.posX = self.posX - 1
            PlaySound('select00', 0.3)
        elseif KeyIsDown('right') then
            self.wait = self.t
            self.posX = self.posX + 1
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            self.wait = self.t
            if self.posX == 12 and self.posY == 6 then
                --由OLC添加，保存rep时菜单用来记录名称的参数
                scoredata.repsaver = self.name
                -- 跳转至保存录像菜单
                lib.save_slot = self.slot
                lib.PushMenuStack(lib.save_replay, { 'left' })
                PlaySound('ok00', 0.3)
            end
            if #self.name == self.lname then
                self.posX = 12
                self.posY = 6
            elseif self.posX == 11 and self.posY == 6 then
                if #self.name ~= 0 then
                    self.name = string.sub(self.name, 1, -2)
                    self.UpdateName()
                end
                PlaySound('cancel00', 0.3)
            elseif self.posX == 10 and self.posY == 6 then
                local char = string.char(0x20)
                self.name = self.name .. char
                self.UpdateName()
                PlaySound('ok00', 0.3)
            else
                local char = string.char(self.keyboard[self.posY * 13 + self.posX + 1])
                self.name = self.name .. char
                self.UpdateName()
                PlaySound('ok00', 0.3)
            end
        elseif KeyIsPressed("spell") or aic.input.CheckLastKey('menu') then
            if #self.name == 0 then
                --由OLC添加，保存rep时菜单用来记录名称的参数
                scoredata.repsaver = self.name
                -- 跳转至保存录像菜单
                lib.save_slot = self.slot
                lib.PushMenuStack(lib.save_replay, { 'left' })
            else
                self.wait = self.t
                self.name = string.sub(self.name, 1, -2)
                self.UpdateName()
            end
            PlaySound('cancel00', 0.3)
        end
    end
end

function lib.name_regist:render()
    SetViewMode('ui')
    ---菜单背景与标题
    local _w, _h = GetTextureSize("general_bg")
    Render('general_bg', self.x, self.y, 0, screen.width / _w, screen.height / _h)
    DrawText('menuttf', 'Name Regist', self.x, self.y + 190, 1.5,
        Color(self.alpha, 47, 45, 42), Color(self.alpha, 255, 255, 255), 'centerpoint')
    lib.DrawTips(self, { l10n.ui.tips.input_char, l10n.ui.tips.delete_char })

    -- 绘制键盘
    -- 未选中按键
    SetFontState("replay", "", Color(255 * self.alpha, unpack(ui.menu.unfocused_color)))
    --是谁写的在Lua里还从0开始数啊（恼）
    --担心哪里会有逻辑出问题就没改了
    --键盘相对菜单中心定位（不能再用screen.height整体偏移，否则进入别的菜单时会错位飘进屏幕）
    local w, h, _y = 18, 15, self.y - 45
    local co
    for x = 0, 12 do
        for y = 0, 6 do    
            if x ~= self.posX or y ~= self.posY then
                co = color(COLOR_WHITE, 255 * self.alpha)
            else
                co = Color(255 * self.alpha, 32, 208, 255)
            end
            if y == 6 then
                if x == 12 then
                    DrawText("main_font_zh_cn", '终',
                        self.x + (x - 5.5) * w, _y - (y - 3.5) * h,
                        0.7, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
                elseif x == 11 then
                    DrawText("main_font_zh_cn", 'BS',
                        self.x + (x - 5.5) * w, _y - (y - 3.5) * h,
                        0.7, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
                else
                    DrawText("main_font_zh_cn", string.char(self.keyboard[y * 13 + x + 1]),
                        self.x + (x - 5.5) * w, _y - (y - 3.5) * h,
                        0.75, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
                end
            else
                DrawText("main_font_zh_cn", string.char(self.keyboard[y * 13 + x + 1]),
                    self.x + (x - 5.5) * w, _y - (y - 3.5) * h,
                    0.75, color(COLOR_BLACK, 255 * self.alpha), co, 'centerpoint')
            end
        end
    end
    
    --名字与成绩数据同样相对菜单中心定位
    local x, y = self.x, self.y + 90
    local lineh = 20
    local yos = (self.l + 1) * lineh * 0.5
    local co1, co2 = { 247, 225, 158 }, { 166, 129, 193 }
    local data = self.data
    DrawText('main_font_zh_cn', l10n.general.character_names.hifuu, x, y + 195, 1.25,
        Color(self.alpha, 221, 221, 85), nil, 'center')
    
    DrawText('main_font_zh_cn', "HARD", x, y + 165, 1.25,
        color(COLOR_WHITE, self.alpha), nil, 'center')
    y = y + 25
    if data then
        local xos = { -275, -250, -80, -30, 130, 220 }
        --高级循环，小子
        for i = 1, 10 do
            if not data[i] then return end
            for j = 0, 5 do
                local align = 'left'
                local text = data[i][j] or 'nil'
                if j == 0 then
                    text = i
                    align = 'right'
                elseif j == 1 then
                    if tonumber(text) then
                        text = string.format("%2d", tonumber(text))
                    end
                    if i == self.score_pos and #text < 8 then text = text .. '_' end
                elseif j == 2 then
                    if tonumber(text) and tonumber(text) < 10000000000 then
                        text = string.format("%9d", tonumber(text))
                    end
                    align = 'right'
                end
                if i == self.score_pos then
                    DrawText("main_font_zh_cn", text, x + xos[j + 1],
                        y - i * lineh + yos + 25, 0.9, Color(self.alpha, 255, 255, 255), nil, align)
                else
                    DrawText("main_font_zh_cn", text, x + xos[j + 1],
                        y - i * lineh + yos + 25, 0.9, Color(self.alpha, 155, 155, 155), nil, align)
                end
            end
        end
        if self.score_pos == 'XX' then
            local i = 'XX'
            if not data[i] then return end
            for j = 0, 5 do
                local align = 'left'
                local text = data[i][j] or 'nil'
                if j == 0 then
                    text = i
                    align = 'right'
                elseif j == 1 then
                    if tonumber(text) then
                        text = string.format("%2d", tonumber(text))
                    end
                    text = text .. '_'
                elseif j == 2 then
                    if tonumber(text) and tonumber(text) < 10000000000 then
                        text = string.format("%9d", tonumber(text))
                    end
                    align = 'right'
                end
                DrawText("main_font_zh_cn", text, x + xos[j + 1],
                    y - 11 * lineh + yos + 25, 0.9, Color(self.alpha, 255, 255, 255), nil, align)
            end
        end
    end

    SetViewMode('world')
end
