local lib = aic.menu

------------------------------------------------------------
---开始游戏前的确认菜单
---由原difficulty_select与player_select合并而来，使用报纸的下半部分
---自机固定为hifuu_player，难度固定为Hard，不再提供选择
---在此菜单按下shoot键即开始游戏

lib.pre_start = Class(object)

---@param pos number @初始选择位置
function lib.pre_start:init()
    self.class = lib.pre_start
    self.num = 3 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP + self.num
    self.bound = false
    self.t = 30
    self.wait = 30
    self.alpha = 255
    self.l = 4
    self.pos = 1
    ----------------------------------------
    ---菜单坐标
    ---基准坐标：title在屏幕中心，pre_start在它正下方一个屏幕
    self.x, self.y = lib.GetScreenCenter()
    self.y = self.y - screen.height
    self.default_x, self.default_y = self.x, self.y
    --每次进入时清掉上一次残留的练习标志（从title进入时若选Practice会重新设置）
    lib.SetPractice(nil)
    lib.RegistMenu(self)
end

function lib.pre_start:frame()
    task.Do(self)
    --只有活跃的菜单才响应玩家操作
    if not lib.IsActive(self) then return end
    self.wait = max(self.wait - 1, 0)
    if self.wait < 1 then
        --开始游戏（或在练习模式下开始练习）
        if KeyIsPressed('shoot') or GetKeyState(KEY.S) then
            self.wait = 114514
            PlaySound('ok00', 0.3)
            lstg.var.player_name = player_list[scoredata.player_select][2]
            lstg.var.rep_player = player_list[scoredata.player_select][3]
            local is_practice = lib.GetPractice() == 'stage'
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
                --Hard是本项目目前唯一的关卡组（后续难度待添加）
                local group = stage.groups.Hard or stage.groups[1]
                if is_practice then
                    --关卡练习：本项目目前只有一个关卡，直接练习它
                    stage.group.PracticeStart(group[1])
                else
                    stage.group.Start(group)
                end
            end)
        end
        --返回标题
        if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
            PlaySound('cancel00', 0.3)
            self.wait = 114514
            --返回时重设练习标志，避免影响下次选择
            lib.SetPractice(nil)
            lib.PopMenuStack()
        end
        --伪难度选择（实际并没有区别）
        if KeyIsDown('up') then
            self.wait = 10
            PlaySound('select00', 0.3)
            if self.pos > 1 then
                self.pos = self.pos - 1
            else
                self.pos = self.l
            end
        elseif KeyIsDown('down') then
            self.wait = 10
            PlaySound('select00', 0.3)
            if self.pos < self.l then
                self.pos = self.pos + 1
            else
                self.pos = 1
            end
        end
    end
end

function lib.pre_start:render()
    SetViewMode('ui')
    lib.DrawTips(self, { l10n.ui.tips.select, l10n.ui.tips.back }, { l10n.ui.tips.select_diff, l10n.ui.tips.back })
    DrawText('menuttf', 'Rank Select', self.x + screen.width * 0.25, self.y + screen.height * 0.315, 1.25,
        Color(255, 47, 45, 42), Color(255, 255, 255, 255), 'centerpoint')
    DrawText('menuttf', 'Player Select', self.x - screen.width * 0.2, self.y - screen.height * 0.2, 1.25,
        Color(255, 47, 45, 42), Color(255, 255, 255, 255), 'centerpoint')
    local d = -60
    local diff = { '志愿服务程度的挑战', '单人完成大作业程度的挑战', '上台假装老师程度的挑战', '科研创新程度的挑战' }
    for i = 1, 4 do
        DrawText('menuttf', '邮专级', self.x + screen.width * 0.35, self.y + screen.height * 0.255 + (i - 1) * d, 1.25,
            Color(255, 255, 255, 255), Color(255, 47, 45, 42), 'right')
        DrawText('menuttf', 'Hard Mode', self.x + screen.width * 0.35, self.y + screen.height * 0.2 + (i - 1) * d, 0.5,
            Color(255, 255, 68, 68), Color(255, 47, 45, 42), 'right')
        DrawText('menuttf', diff[i], self.x + screen.width * 0.35, self.y + screen.height * 0.175 + (i - 1) * d, 0.5,
            Color(255, 255, 255, 255), Color(255, 47, 45, 42), 'right')
        if i == self.pos then
            DrawText('menuttf', '▶', self.x + screen.width * 0.2, self.y + screen.height * 0.225 + (i - 1) * d - 3, 0.75,
                Color(255, 47, 45, 42), Color(255, 255, 255, 255))
        end
    end
    local text = l10n.ui.player_select[1]
    DrawText('menuttf', text[2], self.x - screen.width * 0.1 + 5, self.y + screen.height * 0.125, 1.25,
        Color(255, 255, 255, 255), Color(255, 0, 0, 0), 'centerpoint')
    d = -30
    for i = 1, 4 do
        DrawText('menuttf', text[3][i], self.x - screen.width * 0.3, self.y - screen.height * 0.175 - (5 - i) * d, 0.75,
            Color(255, 255, 255, 255), Color(255, 0, 0, 0))
        DrawText('menuttf', text[4][i], self.x - screen.width * 0.325, self.y - screen.height * 0.2 - 5 - (5 - i) * d, 0.5,
            Color(255, 255, 255, 255), Color(255, 0, 0, 0))
    end
    
    SetViewMode('world')
end
