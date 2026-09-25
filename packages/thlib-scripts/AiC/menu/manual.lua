local lib = aic.menu



---manual（大致与ext的manual相同）
lib.manual = Class(object)

function lib.manual:init(l, t)
    self.class = lib.manual
    self.num = 8
    self.x = screen.width * 0.5
    self.y = screen.height * 0.5
    self.x = self.x + screen.width
    self.y = self.y + screen.height
    self.default_x = self.x
    self.default_y = self.y
    self.pos = 1
    self.t = t or 16
    self.l = l or 4
    self.alpha = 255
    self.scale = 0.5
    self.level = 1
    self.wait = 30
    self.bound = false
    self.flyin = function()
        self.locked = true
        --alpha统一由切换菜单时置为255，这里不再做渐入
        task.New(self, function()
            task.Wait(self.t / 4)
            self.locked = false
        end)
    end
    self.flyout = function(dir)
        self.locked = true
        if dir == 1 then
            task.New(self, function()
                task.MoveTo(self.x, self.y + 20, self.t, 2)
            end)
        elseif dir == -1 then
            task.New(self, function()
                task.MoveTo(self.x, self.y - 20, self.t, 2)
            end)
        elseif dir == 'quit' then
            --本次是直接退回上一级菜单，不会再走flyin把它解锁，所以这里必须解开
            self.locked = false
            lib.PopMenuStack()
        end
    end
    lib.RegistMenu(self)
end

function lib.manual:frame()
    task.Do(self)
    --只有活跃的菜单才响应玩家操作
    if not lib.IsActive(self) then return end
    self.wait = max(self.wait - 1, 0)
    if self.wait < 1 and not self.locked then
        --local lastkey = GetLastKey()
        if self.level == 1 then
            if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
                PlaySound('cancel00', 0.3)
                self.wait = 114514
                lib.PopMenuStack()
            end
            if KeyIsPressed('shoot') then
                PlaySound('ok00', 0.3)
                self.flyout(-1)
                task.New(self, function()
                    task.Wait(self.t)
                    self.level = 2
                    self.x = self.default_x
                    self.y = self.default_y
                    for i = 1, self.t do
                        self.alpha = i * 255 / self.t
                        task.Wait()
                    end
                    self.locked = false
                end)
            end
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
        else
            if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
                PlaySound('cancel00', 0.3)
                self.level = 1
                self.flyout(-1)
                self.flyin()
            end
            if KeyIsDown('up') and self.pos > 1 then
                self.wait = 10
                PlaySound('select00', 0.3)
                self.flyout(-1)
                task.New(self, function()
                    task.Wait(self.t)
                    self.pos = self.pos - 1
                    self.x = self.default_x
                    self.y = self.default_y
                    for i = 1, self.t do
                        self.alpha = i * 255 / self.t
                        task.Wait()
                    end
                    self.locked = false
                end)
            elseif KeyIsDown('down') and self.pos < self.l then
                self.wait = 10
                PlaySound('select00', 0.3)
                self.flyout(1)
                task.New(self, function()
                    task.Wait(self.t)
                    self.pos = self.pos + 1
                    self.x = self.default_x
                    self.y = self.default_y
                    for i = 1, self.t do
                        self.alpha = i * 255 / self.t
                        task.Wait()
                    end
                    self.locked = false
                end)
            end
        end
    end
end

function lib.manual:render()
    SetViewMode('ui')
    ---菜单背景与标题
    local _w, _h = GetTextureSize("general_bg")
    Render('general_bg', self.x, self.y, 0, screen.width / _w, screen.height / _h)
    DrawText('menuttf', 'Manual', self.x, self.y + 190, 1.5,
        Color(self.alpha, 47, 45, 42), Color(self.alpha, 255, 255, 255), 'centerpoint')
    --副标题
    lib.DrawTips(self, { l10n.ui.tips.select, l10n.ui.tips.back })

    local d, x, y = 30, self.x, self.y
    if self.level == 1 then
        if self.locked then
            for i = 1, self.l do
                if i == self.pos then
                    SetImageState('Muki_AiC_help_menu1', '', Color(self.alpha, 255, 255, 255))
                    Render('Muki_AiC_help_menu' .. i, x, y + (5 - i) * d, 0, self.scale)
                else
                    SetImageState('Muki_AiC_help_menu' .. i, '', Color(self.alpha, 64, 64, 64))
                    Render('Muki_AiC_help_menu' .. i, x, y + (5 - i) * d, 0, self.scale)
                end
            end
        else
            for i = 1, self.l do
                if i == self.pos then
                    local co = 159.5 + 95.5 * cos(5 * self.timer)
                    SetImageState('Muki_AiC_help_menu' .. i, '', Color(self.alpha, co, co, co))
                else
                    SetImageState('Muki_AiC_help_menu' .. i, '', Color(self.alpha, 64, 64, 64))
                end
                Render('Muki_AiC_help_menu' .. i, x, y + (5 - i) * d, 0, self.scale)
            end
        end
    else
        SetImageState('Muki_AiC_help' .. self.pos, '', Color(self.alpha, 255, 255, 255))
        Render('Muki_AiC_help' .. self.pos, x, y, 0, self.scale)
    end

    lib.DrawTips(self, { l10n.ui.tips.select, l10n.ui.tips.back })

    SetViewMode('world')
end
