local lib = aic.menu

------------------------------------------------------------
---标题菜单场景的入口

lib.scene = Class(object)

function lib.scene:init()
    lstg.var.aic_version = aic.version
    --初始化PlayerData
    if not scoredata.player_data then
        scoredata.player_data = {}
    end
    for _, p in ipairs({ 'reimu_player', 'marisa_player', 'sakuya_player', "hifuu_player" }) do
        if not scoredata.player_data[p] then
            lib.InitPlayerData(p)
        end
    end
    --初始化MusicRecord
    if not scoredata.music_record then
        scoredata.music_record = {}
    end
    if aic.misc.GetCurrentBGM() ~= 'bgm0' then
        _play_music('bgm0', nil, false)
    end
    self.class = lib.scene
    self.num = 1
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.bound = false
    self.alpha = 0
    --场景必须清空菜单栈，否则从关卡中返回时栈内还留着上次的东西
    lib.ClearMenuStack(0)
    --desk的中心（与title等菜单一起被lib.MoveAll移动）
    self.x, self.y = lib.GetScreenCenter()
    self.default_x, self.default_y = self.x, self.y
    --激活标题菜单（title是菜单栈的栈底，这样PopMenuStack能回到它）
    lib.PushMenuStack(lib.title, { 'none' })
    lib.RegistMenu(self)
end

function lib.scene:frame()
end

---绘制底层大背景desk（1:1，不缩放）
function lib.scene:render()
    SetViewMode('ui')
    Render('desk', self.x, self.y, 0, 1, 1)
    SetViewMode('world')
end
