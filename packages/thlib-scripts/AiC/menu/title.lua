local lib = aic.menu

------------------------------------------------------------
---主菜单
---由原pretitle与title合并而来，使用报纸的上半部分
---刚进入时只显示“Press to Start”，任意键按下后才显示菜单

lib.title = Class(object)

---@param pos number @初始选择位置
---@param l number @菜单长度
function lib.title:init(pos, l)
    self.class = lib.title
    self.num = 2 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP + self.num
    self.bound = false
    self.pos = pos or 1
    self.t = 30
    self.wait = 30
    self.alpha = 255
    --false时只显示Press to Start
    self.started = false
    ----------------------------------------
    ---Press to Start → 菜单的过渡动画
    ---按下shoot后，Press to Start向下移动并渐隐，菜单选项向上移动并渐显，均在60帧内线性完成
    self.anim_time = 15                      --动画总帧数
    self.anim_frame = 0                      --0表示Press to Start状态，1表示菜单已完全展开
    self.pts_fade_dist = screen.height / 10  --Press to Start向下移动的距离
    self.menu_rise_dist = screen.height / 10 --菜单选项向上移动的距离
    ----------------------------------------
    ---菜单坐标
    ---所有菜单常驻在同一个坐标系里，切换活跃菜单时由lib.MoveAll把所有菜单与desk一起平移
    ---基准坐标：title在屏幕中心，pre_start在它正下方一个屏幕
    self.x, self.y = lib.GetScreenCenter()
    self.default_x, self.default_y = self.x, self.y
    self.text =
    {
        "Game Start",
        "Practice",
        "Spell Practice",
        "Replay",
        "Player Data",
        "Music Room",
        "Option",
        "Manual",
        "Quit"
    }
    self.jump =
    {
        { lib.pre_start,   { 'down' } },
        --练习模式并入pre_start，仅多传一个practice标志
        {
            lib.pre_start,
            { 'down' },
            function() lib.SetPractice('stage') end
        },
        {
            lib.spell_practice,
            { 'down', 'right' },
            function() lib.SetPractice('spell') end
        },
        { lib.replay,      { 'left', 'up' } },
        { lib.player_data, { 'right' } },
        { lib.music_room,  { 'up' } },
        { lib.option,      { 'left' } },
        { lib.manual,      { 'right', 'up' } },
        {},
    }
    self.l = l or #self.jump
    --尚未完成的菜单（进入时会提示无效）
    self.invalid_menu = {}
    lib.RegistMenu(self)
end

function lib.title:frame()
    task.Do(self)
    --只有活跃的菜单才响应玩家操作
    if not lib.IsActive(self) then
        return
    end

    self.wait = max(self.wait - 1, 0)
    if self.wait < 1 then
        --Press to Start：等待任意键
        if not self.started then
            if KeyIsPressed('shoot') or KeyIsPressed('spell') or aic.input.CheckLastKey('menu')
                or KeyIsDown('up') or KeyIsDown('down') then
                self.started = true
                PlaySound('ok00', 0.3)
                --Press to Start向下渐隐，菜单选项向上渐显，60帧内线性完成
                task.New(self, function()
                    for i = 1, self.anim_time do
                        self.anim_frame = i / self.anim_time
                        task.Wait()
                    end
                    self.anim_frame = 1
                end)
            end
            return
        end
        --取消键：回到Quit项
        if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
            PlaySound('cancel00', 0.3)
            if self.pos == self.l then
                self.wait = 114514
                task.New(self, function()
                    task.Wait(self.t)
                    stage.QuitGame()
                end)
            else
                self.pos = self.l
            end
            return
        end
        if GetKeyState(KEY.S) then --快速开始
            self.wait = 114514
            PlaySound('ok00', 0.3)
            lib.StartGame()
        end
        if KeyIsPressed('shoot') then
            --尚未完成的菜单
            if aic.table.Search(self.invalid_menu, self.pos) then
                PlaySound('invalid', 0.5)
                return
            end
            if self.pos == self.l then
                self.wait = 114514
                PlaySound('ok00', 0.3)
                task.New(self, function()
                    task.Wait(self.t)
                    stage.QuitGame()
                end)
                return
            end
            self.wait = 114514
            PlaySound('ok00', 0.3)
            if self.jump[self.pos][3] then self.jump[self.pos][3]() end
            if self.jump[self.pos][1] then
                lib.PushMenuStack(self.jump[self.pos][1], self.jump[self.pos][2])
            end
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
    end
end

function lib.title:render()
    SetViewMode('ui')
    ---菜单背景：title.png缩放到宽screen.width、高screen.height*2
    ---随本菜单（即随所有对象）一起移动：
    ---显示title时背景中心在屏幕底部，上半部分正好是整个屏幕；
    ---切到pre_start后整体上移一个屏幕，背景中心升到屏幕中心，屏幕上就是它的下半部分
    local w, h = GetTextureSize("title")
    Render('title', self.x, self.y - screen.height * 0.5, 0, screen.width / w, screen.height * 2 / h)
    ---过渡进度：0为Press to Start状态，1为菜单完全展开
    local p = self.anim_frame
    ---Press to Start：按shoot后向下移动并渐隐
    local pts_alpha = (1 - p) * self.alpha
    DrawText('menuttf', 'Press to Start', self.x, self.y - p * self.pts_fade_dist - 150, 2.5,
        Color(pts_alpha * abs(sin(3 * self.timer)), 47, 45, 42),
        Color(pts_alpha * abs(sin(3 * self.timer)), 255, 255, 255), 'centerpoint')
    ---菜单选项：从下方向上移动并渐显
    local menu_alpha = p * self.alpha
    local d, x, y = 30, self.x + 10, self.y - screen.height * 0.2
    y = y - (1 - p) * self.menu_rise_dist
    for i = 1, self.l do
        DrawText('menuttf', self.text[i], x, y + (5 - i) * d, 1,
            Color(menu_alpha, 47, 45, 42), Color(menu_alpha, 255, 255, 255))
        if i == self.pos then
            DrawText('menuttf', '▶', x - 15, y + (5 - i) * d - 3, 0.75,
                Color(menu_alpha, 47, 45, 42), Color(menu_alpha, 255, 255, 255))
        end
    end
    --版本号是固定在窗口左下角的全局UI，不随菜单坐标移动；
    --固定不动的内容只在活跃时渲染，否则会叠在别的菜单上
    if lib.IsActive(self) then
        DrawText('main_font_zh_cn', "v" .. aic.version, 5, 15, 0.75,
            color(COLOR_WHITE, menu_alpha), nil, "left")
    end
    SetViewMode('world')
end
