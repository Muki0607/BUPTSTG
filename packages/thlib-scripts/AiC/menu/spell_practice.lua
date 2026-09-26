local lib = aic.menu

------------------------------------------------------------
---符卡练习菜单
---列出所有符卡并让玩家选择其一单独练习
---符卡数据来自编辑器生成的_sc_table，每项为：
---{ boss类名, 符卡名, 符卡场景类, 场景编号, 是否包含前一张符卡 }
---选中时设置lstg.var.sc_index，并进入Spell Practice关卡组

lib.spell_practice = Class(object)

---每页显示的符卡数
local LINE_PER_PAGE = 10

---记录上一次选择的位置，以便从练习返回后仍停在原来那张符卡上
lib.spell_practice_last_pos = nil

---获取符卡表
---不能放在init里：菜单是在模块加载阶段创建的，那时编辑器数据还没准备好
---@return table
local function GetSCList()
    local t = sp.copy(_sc_table)
    for k, c in pairs(t) do
        if c[2] == '「通常攻击-显示对话用」' then --排除不应该出现在这里的卡
            t[k] = nil
        end
    end
    return t
end

---总页数
---@return number
local function GetPageCount()
    return max(int((#GetSCList() - 1) / LINE_PER_PAGE) + 1, 1)
end

---按页内位置与页号换算_sc_table索引
---@param pos number @页内位置
---@param page number @页号
---@return number
local function ToIndex(pos, page)
    return pos + page * LINE_PER_PAGE
end

---@param pos number @初始选择位置（_sc_table中的索引）
function lib.spell_practice:init(pos)
    self.class = lib.spell_practice
    self.num = 4 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP + self.num
    self.bound = false
    self.alpha = 255
    self.t = 30
    self.wait = 30
    ----------------------------------------
    ---菜单坐标
    ---基准坐标：title在屏幕中心，本菜单在它右侧一个屏幕
    self.x, self.y = lib.GetScreenCenter()
    self.x = self.x + screen.width
    self.y = self.y - screen.height
    self.default_x, self.default_y = self.x, self.y
    ---0表示未被翻页
    self.page = 0
    if pos then
        self.pos = pos
        self.page = int((pos - 1) / LINE_PER_PAGE)
        self.pos = pos - self.page * LINE_PER_PAGE
    else
        self.pos = 1
    end

    ---开始练习当前选中的符卡
    function self.Start()
        local index = ToIndex(self.pos, self.page)
        if not GetSCList()[index] then
            PlaySound('invalid', 0.5)
            return
        end
        self.wait = 114514
        PlaySound('ok00', 0.3)
        --记录位置，返回时直接停在这张符卡上
        lib.spell_practice_last_pos = index
        --符卡索引，sc_pr.lua据此决定打哪张符卡
        lstg.var.sc_index = index
        --判定进入符卡练习的flag
        stage.IsSCpractice = true
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
            stage.group.PracticeStart('Spell Practice@Spell Practice')
        end)
    end
    lib.RegistMenu(self)
end



function lib.spell_practice:frame()
    task.Do(self)
    --只有活跃的菜单才响应玩家操作
    if not lib.IsActive(self) then return end
    self.wait = max(self.wait - 1, 0)
    if self.wait < 1 then
        local count = #GetSCList()
        --开始练习
        if KeyIsPressed('shoot') then
            self:Start()
        end
        --返回标题
        if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
            PlaySound('cancel00', 0.3)
            self.wait = 114514
            lib.PopMenuStack()
            return
        end
        --选择符卡
        if KeyIsDown('up') then
            self.wait = 10
            PlaySound('select00', 0.3)
            if self.pos > 1 then
                self.pos = self.pos - 1
            else
                self.pos = LINE_PER_PAGE
            end
        elseif KeyIsDown('down') then
            self.wait = 10
            PlaySound('select00', 0.3)
            if self.pos < LINE_PER_PAGE then
                self.pos = self.pos + 1
            else
                self.pos = 1
            end
        --翻页
        elseif KeyIsDown('left') then
            self.wait = 10
            PlaySound('select00', 0.3)
            self.page = (self.page - 1 + GetPageCount()) % GetPageCount()
        elseif KeyIsDown('right') then
            self.wait = 10
            PlaySound('select00', 0.3)
            self.page = (self.page + 1) % GetPageCount()
        end
        --光标不能停在空白项上
        while self.pos > 1 and not GetSCList()[ToIndex(self.pos, self.page)] do
            self.pos = self.pos - 1
        end
        if self.pos > count then self.pos = max(count, 1) end
    end
end

function lib.spell_practice:render()
    SetViewMode('ui')
    ---菜单背景
    local w, h = GetTextureSize("general_bg")
    Render('general_bg', self.x, self.y, 0, screen.width / w, screen.height / h)
    lib.DrawTips(self, { l10n.ui.tips.select, l10n.ui.tips.back }, { l10n.ui.tips.page_up_down })
    local sc_list = GetSCList()
    local page_count = GetPageCount()
    ---行距与列表整体的纵向范围
    local d = 30
    local top = self.y + 150
    ---菜单标题
    DrawText('menuttf', 'Spell Practice', self.x, top + d * 2.2, 1.5,
        Color(self.alpha, 47, 45, 42), Color(self.alpha, 255, 255, 255), 'centerpoint')
    ---页数提示
    DrawText('menuttf', string.format('<  %d / %d  >', self.page + 1, page_count),
        self.x, top + d - 30, 1,
        Color(self.alpha, 47, 45, 42), Color(self.alpha, 255, 255, 255), 'centerpoint')
    ---列出本页所有符卡
    for i = 1, LINE_PER_PAGE do
        local index = i + self.page * LINE_PER_PAGE
        local record = sc_list[index]
        local boss, name
        if record then
            boss = _editor_class[record[1]] and _editor_class[record[1]].name or record[1]
            name = record[2]
        else
            boss, name = '', '---'
        end
        local x, y = self.x, top - i * d
        if i == self.pos then
            DrawText('menuttf', '▶', x - screen.width * 0.32, y + 7, 0.75,
                Color(self.alpha, 47, 45, 42), Color(self.alpha, 255, 255, 255))
            DrawText('main_font_zh_cn', name, x - screen.width * 0.28, y, 0.8,
                Color(self.alpha, 47, 45, 42), Color(self.alpha, 255, 255, 255), 'left', 'vcenter')
            DrawText('main_font_zh_cn', boss, x + screen.width * 0.3, y, 0.7,
                Color(self.alpha, 47, 45, 42), Color(self.alpha, 255, 255, 255), 'right', 'vcenter')
        else
            DrawText('main_font_zh_cn', name, x - screen.width * 0.28, y, 0.8,
                Color(self.alpha, 47, 45, 42), Color(self.alpha, 200, 200, 200), 'left', 'vcenter')
            DrawText('main_font_zh_cn', boss, x + screen.width * 0.3, y, 0.7,
                Color(self.alpha, 47, 45, 42), Color(self.alpha, 200, 200, 200), 'right', 'vcenter')
        end
    end
    SetViewMode('world')
end
