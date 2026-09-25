local lib = aic.menu



---玩家数据
---符卡数据部分因为需要分难度所以暂且搁置
lib.player_data = Class(object)

---@param scnum number @总符卡数
function lib.player_data:init()
    self.class = lib.player_data
    self.num = 11 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP + self.num
    self.x = screen.width * 0.5
    self.y = screen.height * 0.5
    self.x = self.x + screen.width
    self.default_x = self.x
    self.default_y = self.y
    self.bound = false
    self.t = 30
    self.wait = 30
    self.alpha = 255
    self.player_list = { "hifuu_player" }
    self.diff_list = { "Hard" }
    self.sc_list = aic.l10n[setting.locale].ui.sc_list
    self.data = nil
    self.playdata = nil
    self.posX = 1 --自机选择
    self.posY = 3 --难度选择
    self.lX = #self.player_list
    self.lY = #self.diff_list
    self.lsc = 7 --总符卡数
    self.l = 10 --一页中显示的符卡数
    self.page = 1 --当前页数
    self.is_SC_hist = false

    ---获取玩家数据
    ---
    ---由于涉及到scoredata的读取，不能每帧调用，否则会极其卡
    ---@return table
    function self.GetData()
        local data = scoredata.player_data
        local ret = {}
        if data then
            local score = data[self.player_list[self.posX]].high_score[self.posY]
            ret = sp.copy(score)
        end
        self.data = ret
    end

    --我都不知道套了多少层if……这是为了安全起见
    ---获取符卡历史
    ---
    ---由于涉及到scoredata的读取，不能每帧调用，否则会极其卡
    ---@return table
    function self.GetSCHist()
        local hist = scoredata.spell_card_hist or {}
        local ret = {}
        local function GetDefaultSCHist(ret, i)
            table.insert(ret, {
                4 * (i - 1) + self.posY,
                string.rep(l10n.general.punctions.question_mark, min(#self.sc_list[self.posY][i], 21)),
                0,
                0
            })
        end
        for i = 1, self.lsc do
            local sg = hist[self.diff_list[self.posY]]
            if sg then
                local sc = sg[self.sc_list[self.posY][i]]
                if sc then
                    local record = sc[self.player_list[self.posX]]
                    if record then
                        table.insert(ret, {
                            i + self.posY - 1, --符卡编号
                            self.sc_list[self.posY][i], --符卡名
                            record[1], --收取次数
                            record[2] --挑战次数
                        })
                    else
                        GetDefaultSCHist(ret, i)
                    end
                else
                    GetDefaultSCHist(ret, i)
                end
            else
                GetDefaultSCHist(ret, i)
            end
        end
        self.data = ret
    end

    ---获取游戏次数、游玩时长、通关次数
    ---
    ---由于涉及到scoredata的读取，不能每帧调用，否则会极其卡
    ---@return table
    function self.GetPlayData()
        local data = scoredata.player_data
        local ret = {}
        if data then
            ret = {
                data[self.player_list[self.posX]].played_num,
                (function()
                    local time = data[self.player_list[self.posX]].played_time
                    if time < 0 then time = 0 end
                    local h = int(time / 3600)
                    time = time - h * 3600
                    local m = int(time / 60)
                    time = time - m * 60
                    local s = int(time)
                    return string.format("%d:%02d:%02d", h, m, s)
                end)(),
                data[self.player_list[self.posX]].finished_num[self.posY]
            }
        end
        self.playdata = ret
    end

    self.lpage = int(self.lsc / self.l) + 1 --总页数
    lib.RegistMenu(self)
end

function lib.player_data:frame()
    task.Do(self)
    --只有活跃的菜单才响应玩家操作
    if not lib.IsActive(self) then return end
    if not self.init_flag then
        self.GetData()
        self.GetPlayData()
    end
    self.wait = max(self.wait - 1, 0)
    if self.wait < 1 then
        local lastkey = GetLastKey()
        if self.lsc and KeyIsPressed('shoot') then
            if self.page < self.lpage then
                self.page = self.page + 1
            else
                self.page = 1
            end
        end
        if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
            self.wait = 114514
            lib.PopMenuStack()
            PlaySound('cancel00', 0.3)
        end
        if KeyIsPressed('special') then
            self.is_SC_hist = not self.is_SC_hist
        end
        local key = { setting.keys.shoot, setting.keys.up, setting.keys.down,
            setting.keys.left, setting.keys.right }
        --有按键输入时进行一次刷新
        if lastkey ~= KEY.NULL and aic.table.Search(key, lastkey) then
            self.GetPlayData()
            if self.is_SC_hist then
                self.GetSCHist()
            else
                self.GetData()
            end
        end
    end
end

--真的是调参地狱，我不想再碰这玩意了
function lib.player_data:render()
    SetViewMode('ui')
    ---菜单背景（player_data使用同名图片，标题已在图片上）
    local _w, _h = GetTextureSize("player_data")
    Render('player_data', self.x, self.y, 0, screen.width / _w, screen.height / _h)
    lib.DrawTips(self, { nil, l10n.ui.tips.back })
    local x, y = self.x, self.y - 70
    local lineh = 20
    local yos = (self.l + 1) * lineh * 0.5
    local co1, co2 = { 247, 225, 158 }, { 166, 129, 193 }
    local data, playdata = self.data, self.playdata
    if playdata then
        local d = 25
        DrawText('main_font_zh_cn', l10n.general.character_names.hifuu, x, y + 195, 1.25,
            Color(self.alpha, 221, 221, 85), nil, 'center')
        
        DrawText('main_font_zh_cn', "HARD", x, y + 160, 1.25,
            color(COLOR_WHITE, self.alpha), nil, 'center')
        
        for k, v in ipairs({ l10n.ui.player_data.total_play_times, l10n.ui.player_data.play_time, l10n.ui.player_data.finish_times }) do
            DrawText('main_font_zh_cn', v, x - d * 1.25,
                y - k * lineh - 80, 1, color(COLOR_WHITE, self.alpha), nil, 'right')
            DrawText('main_font_zh_cn', playdata[k], x + d * 1.25,
                y - k * lineh - 80, 1, color(COLOR_WHITE, self.alpha), nil, 'left')
        end
    end
    if data then
        --列偏移按参考图重排：行号、机签、分数、时间、是否通关、处理落，各列留有足够宽度
        local xos = { -300, -250, -30, 60, 210, 280 }
        for i = 1, 10 do
            for j = 0, 5 do
                local align = 'left'
                local text = data[i][j]
                if j == 0 then
                    text = i
                    align = 'right'
                elseif j == 1 then
                    if tonumber(text) then
                        text = string.format("%2d", tonumber(text))
                    end
                elseif j == 2 then
                    if tonumber(text) and tonumber(text) < 10000000000 then
                        text = string.format("%9d", tonumber(text))
                    end
                    align = 'right'
                end
                DrawText("main_font_zh_cn", text,
                    x + xos[j + 1], y - i * lineh + yos + 25, 0.9, Color(self.alpha, 255, 255, 255), nil, 'vcenter', align)
            end
        end
    end
    SetViewMode('world')
end
