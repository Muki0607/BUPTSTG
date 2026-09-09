local lib = aic.menu

------------------------------------------------------------

---主菜单
lib.title = Class(object)

---@param pos number @初始选择位置
---@param l number @菜单长度
function lib.title:init(pos, l)
    self.num = 0 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.pos = pos or 1
    self.x = screen.width * 0.8
    self.y = screen.height * 0.3
    self.default_x = screen.width * 0.8
    self.default_y = screen.height * 0.3
    self.bound = false
    self.t = 30
    self.wait = 30
    self.alpha = 0
    self.scale = 0.45
    self.text =
    {
        "Game Start",
        "Practice",
        "Spell Practice",
        "Replay",
        "Library",
        "Music Room",
        "Option",
        "Manual",
        "Quit"
    }
    self.jump =
    {
        { lib.difficulty_select },
        {
            lib.difficulty_select,
            function() practice = 'stage' end,
        },
        {
            lib.spell_practice,
            function() practice = 'spell' end
        },
        { lib.replay },
        { lib.library },
        { lib.music_room },
        { lib.option },
        { lib.manual },
        { lib.pretitle }
    }
    self.l = l or #self.jump
    lib.Fly(self, 1, 'left')
    lstg.tmpvar.current_menu = self

    self.invalid_menu = { 2, 3 }
    if aic.misc.GetCurrentBGM() ~= 'aic_bgm1' then
        _play_music('aic_bgm1', nil, false)
    end
end

function lib.title:frame()
    task.Do(self)

    self.wait = max(self.wait - 1, 0)
    if self.wait < 1 then
        local lastkey = GetLastKey()
        --高速开始
        if lastkey == KEY.S then
            if not scoredata.player_select then return end
            New(tasker, function()
                task.New(self, function()
                    lib.BgmFadeOut(aic.misc.GetCurrentBGM(), 59)
                end)
                lstg.var.player_name = player_list[scoredata.player_select][2]
                lstg.var.rep_player = player_list[scoredata.player_select][3]
                Del(self)
                if _debug.skip_loading or GetKeyState(KEY.S) then
                    New(mask_fader, 'close')
                    task.Wait(30)
                    New(mask_fader, 'open')
                else
                    New(aic.misc.loading_scene)
                    task.Wait(270)
                    New(mask_fader, 'open')
                end
                if stage.groups.SpellCard then
                    stage.group.Start(stage.groups.SpellCard)
                else
                    --其他难度待添加
                    stage.group.Start(stage.groups.Normal)
                end
            end)
        end
        if KeyIsPressed('spell') or aic.input.CheckLastKey('menu') then
            PlaySound('cancel00', 0.3)
            if self.pos == self.l then
                self.wait = 114514
                lib.PopMenuStackWithDir('down')
            else
                self.pos = self.l
            end
        end
        if KeyIsPressed('shoot') then
            if not aic.table.Search(self.invalid_menu, self.pos) then
                self.wait = 114514
                PlaySound('ok00', 0.3)
                lib.Fly(self, 0, 'left')
            end
            if self.pos == self.l then
                lib.PopMenuStackWithDir('down')
                return
            elseif aic.table.Search(self.invalid_menu, self.pos) then
                PlaySound('invalid', 0.5)
                return
            end
            if self.jump[self.pos][2] then self.jump[self.pos][2]() end
            self.param = { self.pos }
            lib.PushMenuStack(self.jump[self.pos][1])
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
    SetImageState('logo', '', Color(self.alpha, 255, 255, 255))
    if self.timer <= self.t or self.wait > 9999 then
        Render('logo', screen.width * 0.2, screen.height * 0.9, 0, 0.75)
    else
        Render('logo', self.x - screen.width * 0.6, self.y + screen.height * 0.6, 0, 0.75)
    end
    --local colors = { Color(255, 255, 0, 0), Color(255, 255, 0, 0),
    --    Color(255, 0, 255, 255), Color(255, 0, 255, 255) }
    local d, x, y = 30, self.x - 180, self.y + 50
    for i = 1, self.l do
        local co
        if i == self.pos then
            co = Color(self.alpha, 32, 208, 255)
        else
            co = Color(self.alpha, 255, 255, 255)
        end
        --Render('Muki_AiC_menu_title' .. i, x, y + (5 - i) * d, 0, self.scale)
        DrawText('main_font_en_us', self.text[i], x, y + (5 - i) * d, 1.5,
            Color(self.alpha, 85, 76, 74), co, 'centerpoint')
    end
    DrawText('main_font_zh_cn', "v" .. aic.version, 5, 15, 0.75,
        color(COLOR_WHITE, self.alpha), nil, "left")
    SetViewMode('world')
end
