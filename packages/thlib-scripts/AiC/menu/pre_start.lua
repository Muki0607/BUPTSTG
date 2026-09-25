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
    self.layer = LAYER_TOP
    self.bound = false
    self.t = 30
    self.wait = 30
    self.alpha = 0
    self.l = 4
    self.pos = 1
    ----------------------------------------
    ---菜单坐标
    ---基准坐标：title在屏幕中心，pre_start在它正下方一个屏幕
    self.x, self.y = lib.GetScreenCenter()
    self.y = self.y - screen.height
    self.default_x, self.default_y = self.x, self.y
    lib.RegistMenu(self)
end

function lib.pre_start:frame()
    task.Do(self)
    --只有活跃的菜单才响应玩家操作
    if not lib.IsActive(self) then return end
    self.wait = max(self.wait - 1, 0)
    if self.wait < 1 then
        --开始游戏
        if KeyIsPressed('shoot') or GetKeyState(KEY.S) then
            self.wait = 114514
            PlaySound('ok00', 0.3)
            lib.StartGame()
        end
        --返回标题
        if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
            PlaySound('cancel00', 0.3)
            self.wait = 114514
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
    DrawText('menuttf', 'Rank Select', self.x + screen.width * 0.25, self.y + screen.height * 0.3, 1.25,
        Color(255, 47, 45, 42), Color(255, 255, 255, 255), 'centerpoint')
    DrawText('menuttf', 'Player Select', self.x - screen.width * 0.2, self.y - screen.height * 0.2, 1.25,
        Color(255, 47, 45, 42), Color(255, 255, 255, 255), 'centerpoint')
    local d = -60
    local diff = { '志愿服务程度的挑战', '单人完成大作业程度的挑战', '上台假装老师程度的挑战', '科研创新程度的挑战' }
    for i = 1, 4 do
        DrawText('main_font_zh_cn', '邮专级', self.x + screen.width * 0.25, self.y + screen.height * 0.225 + (i - 1) * d, 1.25,
            Color(255, 255, 255, 255), Color(255, 47, 45, 42), 'centerpoint')
        DrawText('menuttf', 'BUPT Mode', self.x + screen.width * 0.25, self.y + screen.height * 0.19 + (i - 1) * d, 0.5,
            Color(255, 255, 68, 68), Color(255, 47, 45, 42), 'centerpoint')
        DrawText('main_font_zh_cn', diff[i], self.x + screen.width * 0.25, self.y + screen.height * 0.165 + (i - 1) * d, 0.75,
            Color(255, 255, 255, 255), Color(255, 47, 45, 42), 'centerpoint')
        if i == self.pos then
            DrawText('menuttf', '▶', self.x + screen.width * 0.15, self.y + screen.height * 0.225 + (i - 1) * d, 0.75,
                Color(255, 47, 45, 42), Color(255, 255, 255, 255))
        end
    end
    
    SetViewMode('world')
end
