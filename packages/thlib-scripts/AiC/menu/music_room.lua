local lib = aic.menu

---音乐相关的函数，因为经常暴毙所以套一层TryExcept

--- 获取全局音乐音量
---@return number
function lib.GetBGMVolume()
    return GetBGMVolume()
end

--- 设置全局音乐音量
--- 当参数为 2 个时，设置指定音乐的音量
--- 不知道为啥有些时候只传一个参数会炸，只能手动模拟了
---@param bgmname string
---@param volume number
---@overload fun(volume:number)
function lib.SetBGMVolume(bgmname, volume)
    if bgmname == 'all' or type(bgmname) == 'number' then
        local _, bgm = EnumRes('bgm')
        for _, v in pairs(bgm) do
            SetBGMVolume(v, volume or bgmname)
        end
    else
        SetBGMVolume(bgmname, volume)
    end
end

---@param bgmname string
function lib.PauseMusic(bgmname)
    PauseMusic(bgmname)
end

---@param bgmname string
function lib.ResumeMusic(bgmname)
    ResumeMusic(bgmname)
end

---@param bgmname string
---@return lstg.AudioStatus
function lib.GetMusicState(bgmname)
    return GetMusicState(bgmname)
end

--[[
for _, v in ipairs({ 'GetBGMVolume', 'SetBGMVolume', 'PauseMusic', 'ResumeMusic', 'GetMusicState' }) do
    lib[v] = function(bgmname, volume)
        TryExcept(function()
                lstg[v](bgmname, volume)
            end,
            { [''] = pass })
    end
end
--]]

------------------------------------------------------------
---音乐室

lib.music_room = Class(object)

function lib.music_room:init(pos, l)
    self.class = lib.music_room
    self.num = 6 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP + self.num
    self.pos = pos or 1
    self.prepos1 = self.pos --前一个选择
    self.prepos2 = self.pos --前前一个选择
    self.headpos = 1 --显示的第一首bgm，决定所有bgm的位置
    self.textpos = 1 --下方评论对应的曲目
    self.truepos = 1 --光标所在位置
    self.warn1 = false --是否触发警告1
    self.warn2 = false --是否触发警告2
    self.random_text = '' --紫的曲子用的随机字符
    self.music_pos = 0 --音乐当前播放位置，由于没有能直接获取的函数，只能手动计时
    self.playing = false --当前是否在播放，虽然进入时在播放标题bgm但无法获得当前播放位置所以初始为false
    self.curr_bgm = 'bgm0'
    self.x = screen.width * 0.5
    self.y = screen.height * 0.5
    self.y = self.y + screen.height
    self.default_x = self.x
    self.default_y = self.y
    self.bound = false
    self.t = 8
    self.wait = 30
    self.alpha = 255
    self.text_alpha = 255
    self.lbgm = 4 --总bgm数
    self.l = 4 --一页显示bgm数
    self.debug = _debug.music_room_debug
    local text = aic.l10n[setting.locale].ui.music_room_text
    self.text1 = text.title
    self.text2 = text.comment
    self.text3 = text.warn1
    ---检查bgm是否播放过
    ---@param num number @要检测的bgm编号
    function self.CheckRecord(num)
        return scoredata.music_record['bgm' .. num]
    end
    lib.RegistMenu(self)
end

function lib.music_room:frame()
    task.Do(self)
    --只有活跃的菜单才响应玩家操作
    if not lib.IsActive(self) then return end
    self.wait = max(self.wait - 1, 0)
    self.curr_bgm = aic.misc.GetCurrentBGM() or self.curr_bgm --当前播放bgm，若暂停则为暂停前播放bgm
    if self.playing then
        self.music_pos = self.music_pos + 1
    end
    if self.wait < 1 then
        --local lastkey = GetLastKey()
        if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
            self.wait = 114514
            lib.SetBGMVolume(setting.bgmvolume)
            PlaySound('cancel00', 0.3)
            lib.PopMenuStack()
        elseif KeyIsPressed('shoot') then
            self.wait = self.t
            if self.pos ~= self.textpos then self.warn1 = false end
            self.textpos = self.pos
            if self.CheckRecord(self.pos) or self.warn1 then
                self.warn1 = false
                task.New(self, function()
                    lib.SetBGMVolume(setting.bgmvolume)
                    TryExcept(function()
                            _play_music('bgm' .. self.pos, nil, false)
                            self.playing = true
                            self.music_pos = 0
                        end,
                        { [''] = pass })
                    for t = 1, 30 do
                        self.text_alpha = 255 / 30 * t
                    end
                end)
            else
                self.warn1 = true
            end
        elseif KeyIsDown('up') then
            self.wait = self.t
            PlaySound('select00', 0.3)
            if self.pos > 1 then
                self.prepos2 = self.prepos1
                self.prepos1 = self.pos
                self.pos = self.pos - 1
                --处理显示范围改变的问题
                if self.truepos == 1 then
                    self.headpos = self.headpos - 1
                else
                    self.truepos = self.truepos - 1
                end
            end
        elseif KeyIsDown('down') then
            self.wait = self.t
            PlaySound('select00', 0.3)
            if self.pos < self.lbgm then
                self.prepos2 = self.prepos1
                self.prepos1 = self.pos
                self.pos = self.pos + 1
                --处理显示范围改变的问题
                if self.truepos == 10 then
                    self.headpos = self.headpos + 1
                    
                else
                    self.truepos = self.truepos + 1
                end
            end
        elseif KeyIsDown('special') then
            self.wait = self.t
            if aic.misc.GetCurrentBGM() then
                lib.PauseMusic(self.curr_bgm)
                self.playing = false
            else
                lib.ResumeMusic(self.curr_bgm)
                self.playing = true
            end
        end
    end
end

function lib.music_room:render()
    SetViewMode('ui')
    ---菜单背景与标题（music_room使用同名图片）
    local w, h = GetTextureSize("music_room")
    Render('music_room', self.x, self.y, 0, screen.width / w, screen.height / h)
    lib.DrawTips(self, { l10n.ui.tips.play_music, l10n.ui.tips.back, l10n.ui.tips.pause_continue_music }, { l10n.ui.tips.select_music })
    local d, x, y, text1 = 20, self.x - 260, self.y + 110, self.text1
    local dx = 150
    for i = 1, self.l do
        local pos, text = i + self.headpos - 1
        local title
        if self.CheckRecord(pos) then
            title = text1[pos]
        else
            title = string.rep(l10n.general.terms.unknown, 3)
        end
        text = 'No.　' .. pos .. '　' .. title
        if pos == self.pos then
            DrawText("main_font_zh_cn", text, x + dx - 10, y + (2.5 - i) * d, 0.9,
                Color(self.alpha, 223, 223, 103), color(COLOR_BLACK, self.alpha))
        elseif pos == self.prepos1 then
            DrawText("main_font_zh_cn", text, x + dx, y + (2.5 - i) * d, 0.9,
                Color(self.alpha, 154, 154, 129), color(COLOR_BLACK, self.alpha))
        elseif pos == self.prepos2 then
            DrawText("main_font_zh_cn", text, x + dx, y + (2.5 - i) * d, 0.9,
                Color(self.alpha, 134, 134, 129), color(COLOR_BLACK, self.alpha))
        else
            DrawText("main_font_zh_cn", text, x + dx, y + (2.5 - i) * d, 0.9,
                Color(self.alpha, 129, 129, 129), color(COLOR_BLACK, self.alpha))
        end
    end
    local alpha = min(self.alpha, self.text_alpha)
    local dx, dy, note_dx, warn_dx = -80, -170, 40, 100
    if self.CheckRecord(self.textpos) or not self.warn1 then
        DrawText("main_font_en_us", '    ♪ ', x + dx + note_dx, y + dy, 1, color(COLOR_WHITE, alpha), color(COLOR_BLACK, alpha))
        DrawText("main_font_zh_cn", '            ' .. text1[self.textpos] .. '\n' .. self.text2[self.textpos],
            x + dx, y + dy, 1, color(COLOR_WHITE, alpha), color(COLOR_BLACK, alpha))
    else
        DrawText("main_font_zh_cn", '            ' .. '\n' .. self.text3,
            x + dx + warn_dx, y + dy, 1, color(COLOR_RED, alpha), color(COLOR_BLACK, alpha))
    end
    if self.debug then
        local str = tostring
        DrawText("main_font_zh_cn", 'warn1=' .. str(self.warn1) .. '\nwarn2=' .. str(self.warn2)
            .. '\npos=' .. self.pos .. '\ntextpos=' .. self.textpos .. '\ncurr_bgm=' .. self.curr_bgm, x + 180, y + 60, 1,
            color(COLOR_WHITE, alpha), color(COLOR_BLACK, alpha))
        local music_pos = int(self.music_pos / 60)
        DrawText("main_font_zh_cn", l10n.ui.music_room.curr_play_pos .. int(music_pos / 60) .. ':' .. (music_pos % 60), x + 180, y - 90, 1,
            color(COLOR_WHITE, alpha), color(COLOR_BLACK, alpha))
    end
    SetViewMode('world')
end
