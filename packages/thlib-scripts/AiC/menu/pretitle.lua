local lib = aic.menu

------------------------------------------------------------

---主菜单前的标题（Press Start界面）
lib.pretitle = Class(object)

function lib.pretitle:init()
    lstg.var.aic_version = aic.version
    --初始化PlayerData
    if not scoredata.player_data then
        scoredata.player_data = {}
    end
    for _, p in ipairs({ 'reimu_player', 'marisa_player', 'sakuya_player', 'muki_player', 'nenyuki_player' }) do
        if not scoredata.player_data[p] then
            lib.InitPlayerData(p)
        end
    end
    --初始化MusicRecord
    if not scoredata.music_record then
        scoredata.music_record = {}
    end
    self.num = -1 --菜单编号
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.x = screen.width * 0.75
    self.y = screen.height * 0.25
    self.default_x = screen.width * 0.75
    self.default_y = screen.height * 0.25
    self.bound = false
    self.t = 30
    self.wait = 30
    self.alpha = 0
    self.scale = 0.45
    lib.Fly(self, 1, 'left')
    lstg.tmpvar.current_menu = self

    if #lib.menu_stack == 0 then table.insert(lib.menu_stack, lib.pretitle) end
    lib.ClearMenuStack() --这里必须清空栈，否则从关卡中返回时虽然回到主菜单，但菜单栈中仍有东西

    --有结局先放结局
    if lib.EndingFlag then
        lib.PushMenuStack(lib.ending)
    end
    --结局放完再存rep
    if lib.last_replay and not lib.EndingFlag then
        lib.PushMenuStack(lib.name_regist)
    end
    if aic.misc.GetCurrentBGM() ~= 'aic_bgm1' then
        _play_music('aic_bgm1', nil, false)
    end
end

function lib.pretitle:frame()
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
            task.New(self, function()
                task.Wait(self.t)
                stage.QuitGame()
            end)
        end
        if KeyIsPressed('shoot') then
            lib.PushMenuStackWithDir(lib.title, 'up')
        end
    end
end

function lib.pretitle:render()
    SetViewMode('ui')
    SetImageState('logo', '', Color(self.alpha, 255, 255, 255))
    Render('logo', screen.width * 0.2, screen.height * 0.9, 0, 0.75) --pretitle中logo位置是写死的
    --local colors = { Color(255, 255, 0, 0), Color(255, 255, 0, 0),
    --    Color(255, 0, 255, 255), Color(255, 0, 255, 255) }
    local x, y = self.x, self.y
    DrawText('main_font_en_us', 'Press to Start', screen.width * 0.5, y, 2.5,
        Color(self.alpha, 255, 255, 255), Color(self.alpha, 0, 0, 0), 'centerpoint')
    DrawText('main_font_zh_cn', "v" .. aic.version, 5, 15, 0.75,
        color(COLOR_WHITE, self.alpha), nil, "left")
    SetViewMode('world')
end
