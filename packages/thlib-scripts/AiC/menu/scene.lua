local lib = aic.menu

------------------------------------------------------------
---标题菜单场景的入口

lib.scene = Class(object)

function lib.scene:init()
    --创建所有菜单实例（必须等到类注册完成之后，不能在脚本加载阶段创建）
    lib.NewMenus()
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
    if aic.misc.GetCurrentBGM() ~= 'bgm1' then
        _play_music('bgm1', nil, false)
    end
    self.class = lib.scene
    self.num = 1
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP + self.num
    self.bound = false
    self.alpha = 255
    --场景必须清空菜单栈，否则从关卡中返回时栈内还留着上次的东西
    lib.ClearMenuStack(false)
    --desk的中心（与title等菜单一起被lib.MoveAll移动）
    self.x, self.y = lib.GetScreenCenter()
    self.default_x, self.default_y = self.x, self.y
    --必须先注册自身，再切换菜单：lib.MoveAll遍历的是lib.instances，
    --若注册晚于PushMenuStack，第一次切换时desk不在名单里，不会跟着一起移动
    lib.RegistMenu(self)
    --激活标题菜单（title是菜单栈的栈底，这样PopMenuStack能回到它）
    lib.PushMenuStack(lib.title, { 'none' })
end

function lib.scene:frame()
    --必须推进自身的task，否则lib.Fly挂在scene上的移动协程不会执行，desk不会跟着移动
    task.Do(self)
end

---绘制底层大背景desk（1:1，不缩放）
function lib.scene:render()
    SetViewMode('ui')
    Render('desk', self.x, self.y, 0, 1, 1)
    SetViewMode('world')
end
