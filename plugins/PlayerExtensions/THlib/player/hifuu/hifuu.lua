hifuu_player = Class(player_class)

-- 梅莉水面bomb特效（用 Include 加载，afterTHlib 阶段 require 搜索路径不含 thlib-scripts 根）
Include('THlib/player/hifuu/merry/water_ripple.lua')
local water = hifuu_water_ripple

local lib = {}
local bullet_light_to_dark = {
    ball_mid_b = ball_mid,
    ball_mid_d = ball_mid_c,
    ball_huge = ball_huge_dark,
    ball_light = ball_light_dark,
    water_drop = water_drop_dark,
}
function lib.load_resource()
    LoadImageFromFile('hifuu_switch_ef', 'THlib/player/hifuu/hifuu_switch_ef.png')
    --- renko
    LoadTexture('hifuu_player_renko', 'THlib/player/hifuu/renko/renko.png')
    LoadTexture('hifuu_player_renko_ef', 'THlib/player/hifuu/renko/renko_ef.png')
    LoadTexture('hifuu_kekkai', 'THlib/player/hifuu/renko/reimu_kekkai.png')
    LoadTexture('hifuu_orange_ef2', 'THlib/player/hifuu/renko/reimu_orange_eff.png')
    -----------------------------------------
    LoadImageGroup('hifuu_player_renko', 'hifuu_player_renko', 0, 0, 640, 640, 8, 3, 0.5, 0.5)
    for i = 1, 24 do
        SetImageScale('hifuu_player_renko' .. i, 0.08)
    end
    ----------------------------------------
    LoadImage('hifuu_bullet_ef_img', 'hifuu_player_renko_ef', 48, 144, 16, 16)
    --- 主炮
    LoadTexture('hifuu_res_renko', 'THlib/player/hifuu/renko/hifuu_res_renko.png')
    LoadImage('hifuu_bullet_renko_main', 'hifuu_res_renko', 0, 0, 52, 32)
    SetImageState('hifuu_bullet_renko_main', '', Color(0xA0FFFFFF))
    SetImageCenter('hifuu_bullet_renko_main', 26, 16)
    LoadAnimation('hifuu_bullet_renko_main_ef', 'hifuu_res_renko', 64, 0, 32, 32, 4, 1, 4)
    SetAnimationState('hifuu_bullet_renko_main_ef', 'mul+add', Color(0xA0FFFFFF))

    LoadImage('hifuu_bullet_renko_sub', 'hifuu_res_renko', 0, 32, 64, 32, 16, 16)
    SetImageState('hifuu_bullet_renko_sub', '', Color(0x60FFFFFF))
    SetImageCenter('hifuu_bullet_renko_sub', 32, 16)
    LoadAnimation('hifuu_bullet_renko_sub_ef', 'hifuu_res_renko', 64, 32, 48, 32, 4, 1, 4)
    SetAnimationState('hifuu_bullet_renko_sub_ef', 'mul+add', Color(0xA0FFFFFF))
    -----------------------------------------
    LoadImage('hifuu_bullet_orange', 'hifuu_player_renko_ef', 64, 176, 64, 16, 64, 16)
    SetImageState('hifuu_bullet_orange', '', Color(0x80FFFFFF))
    SetImageCenter('hifuu_bullet_orange', 32, 8)
    LoadImage('hifuu_bullet_orange_ef', 'hifuu_player_renko_ef', 64, 176, 64, 16, 64, 16)
    SetImageState('hifuu_bullet_orange_ef', '', Color(0x80FFFFFF))
    SetImageCenter('hifuu_bullet_orange_ef', 32, 8)
    LoadAnimation('hifuu_bullet_orange_ef2', 'hifuu_orange_ef2', 0, 0, 64, 16, 1, 9, 1)
    SetAnimationCenter('hifuu_bullet_orange_ef2', 0, 8)
    SetAnimationState('hifuu_bullet_orange_ef2', 'mul+add', Color(255, 255, 155, 155))
    -----------------------------------------
    LoadTexture('hifuu_support', 'THlib/player/hifuu/hifuu_support.png')
    LoadAnimation('hifuu_support_renko', 'hifuu_support', 0, 0, 64, 64, 4, 1, 60)
    SetAnimationState('hifuu_support_renko', 'mul+alpha', Color(255, 255, 255, 255))
    LoadImageFromFile('hifuu_bomb_ef', 'THlib/player/hifuu/renko/reimu_bomb_ef.png')
    LoadImage('hifuu_kekkai', 'hifuu_kekkai', 0, 0, 256, 256, 0, 0)
    SetImageState('hifuu_kekkai', 'mul+add', Color(0x804040FF))
    LoadPS('hifuu_bullet_ef', 'THlib/player/hifuu/renko/reimu_bullet_ef.psi', 'hifuu_bullet_ef_img')
    LoadPS('hifuu_sp_ef', 'THlib/player/hifuu/renko/reimu_sp_ef.psi', 'parimg1', 16, 16)
    LoadAniFromFile('hifuu_blade_aura', 'THlib/player/hifuu/renko/hifuu_blade_aura.png', true, 4, 1, 8)
    SetAnimationCenter('hifuu_blade_aura', 64, 64)
    -----------------------------------------
    --- merry
    LoadTexture('hifuu_player_merry', 'THlib/player/hifuu/merry/merry.png')
    LoadImageGroup('hifuu_player_merry', 'hifuu_player_merry', 0, 0, 640, 640, 8, 3, 0.5, 0.5)
    for i = 1, 24 do
        SetImageScale('hifuu_player_merry' .. i, 0.08)
    end

    LoadTexture('hifuu_res_merry', 'THlib/player/hifuu/merry/hifuu_res_merry.png')
    LoadTexture('hifuu_laser_normal', 'THlib/player/hifuu/merry/hifuu_laser_normal.png')
    LoadTexture('hifuu_laser_heartbeat', 'THlib/player/hifuu/merry/hifuu_laser_heartbeat.png')
    LoadImage('hifuu_bullet_heart', 'hifuu_res_merry', 0, 0, 60, 34, 16, 16)
    SetImageState('hifuu_bullet_heart', '', Color(0x30FFFFAA))
    SetImageCenter('hifuu_bullet_heart', 30, 17)
    LoadAnimation('hifuu_bullet_heart_ef', 'hifuu_res_merry', 60, 0, 40, 34, 4, 1, 4)
    SetAnimationState('hifuu_bullet_heart_ef', 'mul+add', Color(0xA0FFFFFF))
    ----------------------------------------
    LoadTexture('marisa_player', 'THlib/player/hifuu/merry/marisa.png')
    LoadImage('hifuu_laser_light', 'marisa_player', 224, 224, 32, 32)
    SetImageState('hifuu_laser_light', 'mul+add', Color(0xFFFFFFFF))
    LoadImageFromFile('hifuu_laser_hit_par', 'THlib/player/hifuu/merry/merry_hit_par.png')
    LoadPS('merry_hit', 'THlib/player/hifuu/merry/merry_hit.psi', 'hifuu_laser_hit_par')
    -----------------------------------------
    LoadAnimation('hifuu_support_merry', 'hifuu_support', 0, 64, 64, 64, 4, 1, 30)
    SetAnimationState('hifuu_support_merry', 'mul+add', Color(200, 255, 255, 255))

    water.load('THlib/player/hifuu/merry/hifuu_water_background.png')
    ---
end

function hifuu_player:init(slot)
    lib.load_resource()
    player_class.init(self)
    self.name = 'Hifuu'
    self.hspeed = 4.5
    self.lspeed = 2.0
    self.imgs = {}
    self.A = 0.5
    self.B = 0.5

    self.into_slow = 0
    self.offset = { 600, 600 }

    for i = 1, 24 do self.imgs[i] = 'hifuu_player_renko' .. i end

    self.slist =
    {
        { nil,               nil,             nil,                nil },
        { { 0, -32, 0, -32 }, nil,            nil,                nil },
        { { -30, -10, -15, -20 }, { 30, -10, 15, -20 }, nil,      nil },
        { { -30, -10, -15, -20 }, { 30, -10, 15, -20 }, { 0, -32, 0, -32 }, nil },
        { { -30, -10, -15, -20 }, { 30, -10, 15, -20 }, { -15, -32, -7.5, -32 }, { 15, -32, 7.5, -32 } },
        { { -30, -10, -15, -20 }, { 30, -10, 15, -20 }, { -15, -32, -7.5, -32 }, { 15, -32, 7.5, -32 } },
    }
    self.anglelist =
    {
        { 90,  90,  90, 90 },
        { 90,  90,  90, 90 },
        { 100, 80,  90, 90 },
        { 100, 90,  80, 90 },
        { 110, 100, 80, 70 },
    }

    --- 莲子高速bomb
    self.blade_range       = 22 -- 撞击判定半径（自机碰撞盒大小）
    self.blade_duration    = 180 -- 冲刺持续帧数（3秒）
    self.blade_hspeed      = 9 -- 冲刺期间移动速度
    self.blade_base_dmg    = 200 -- 撞到敌人的基础伤害（占位，慢慢调）
    self.blade_per_bullet  = 5 -- 每消一颗子弹的伤害加成（占位）
    self.blade_dmg_cap     = 400 -- 单个敌人伤害上限（占位）
    self.bladeing          = false -- 内部状态标志
    self.blade_timer       = 0
    self.blade_hit_enemy   = {}
    self.blade_hit_bullet  = {}

    --- 梅莉低速bomb：水面涟漪
    self.water_duration    = 240 -- bomb总时长（帧），4秒
    self.water_expand_time = 45 -- 阶段1：水面展开时长（帧）
    self.water_fade_time   = 75 -- 阶段3：淡出时长（帧）
    self.water_dmg         = 1.75 -- 每帧对范围内敌人的伤害（靠碰撞体，与灵梦结界一致）
    self.water_max_radius  = 500 -- 水面最大作用半径（世界坐标，用于消弹与伤害范围）
    ---
    self.spellname         = { '以太「量子隧穿」', '境界「另一侧的月」' }
end

-------------------------------------------------------
function hifuu_player:shoot()
    if self.nextspell <= 0 then
        --spell状态下不会发弹

        if self.slow == 1 then
            --低速（激光，持续发射）

            if self.fire == 1 then
                if self.timer % 12 == 0 then PlaySound('lazer02', 0.025) end
                local angle = 90 -- 固定向上
                for i = 1, 2 do -- 只发射2根
                    self.offset[i] = 600
                    -- 左右各一根，间距比如 ±10
                    local x = self.x + (i == 1 and -10 or 10)
                    local y = self.y + 20

                    local target = nil
                    for j, o in ObjList(GROUP_ENEMY) do
                        if o.colli and lib.IsInLaser(x, y, angle, o, 50) then
                            local d = Dist(o.x, o.y, x, y)
                            if d < self.offset[i] then
                                target = o
                                self.offset[i] = d
                            end
                        end
                    end
                    for j, o in ObjList(GROUP_NONTJT) do
                        if o.colli and lib.IsInLaser(x, y, angle, o, 50) then
                            local d = Dist(o.x, o.y, x, y)
                            if d < self.offset[i] then
                                target = o
                                self.offset[i] = d
                            end
                        end
                    end
                    if target then
                        self.offset[i] = max(0, self.offset[i] - target.b)
                        New(merry_laser_hit, x + self.offset[i] * cos(angle), y + self.offset[i] * sin(angle))
                        if target.class.base.take_damage then
                            target.class.base.take_damage(target, 0.25)
                        end
                        if target.hp > target.maxhp * 0.1 then
                            PlaySound('damage00', 0.3, target.x / 1024)
                        else
                            PlaySound('damage01', 0.6, target.x / 1024)
                        end
                    end
                end
            end

            if self.timer % 8 < 4 then
                PlaySound('plst00', 0.3, self.x / 1024)
                local num = int(lstg.var.power / 100) + 1
                for i = 1, 4 do
                    if self.sp[i] and self.sp[i][3] > 0.5 then
                        New(hifuu_bullet_heart, 'hifuu_bullet_heart', self.supportx + self.sp[i][1],
                            self.supporty + self.sp[i][2], 8, self.anglelist[num][i], self.target, 900, 0.5)
                    end
                end
            end
        else
            --高速（普通弹幕）
            self.nextshoot = 4 -- 标准射速
            PlaySound('plst00', 0.3, self.x / 1024)
            New(hifuu_bullet_renko_main, 'hifuu_bullet_renko_main', self.x + 10, self.y, 24, 90, 2)
            New(hifuu_bullet_renko_main, 'hifuu_bullet_renko_main', self.x - 10, self.y, 24, 90, 2)
            if self.support > 0 then
                if self.timer % 8 < 4 then
                    for i = 1, 4 do
                        if self.sp[i] and self.sp[i][3] > 0.5 then
                            for j = -2, 2 do
                                New(hifuu_bullet_renko_sub, 'hifuu_bullet_renko_sub', self.supportx + self.sp[i][1],
                                    self.supporty + self.sp[i][2], 12, 90 + j * 15 + j * 5 * sin(1.5 * self.timer), 0.3)
                            end
                        end
                    end
                end
            end
        end
    end
end

-------------------------------------------------------
function hifuu_player:spell()
    self.collect_line = self.collect_line - 300
    New(tasker, function()
        task.Wait(90)
        self.collect_line = self.collect_line + 300
    end)
    if self.slow == 1 then
        -- 梅莉低速bomb：水面涟漪
        PlaySound('power1', 0.8)
        PlaySound('cat00', 0.8)
        misc.ShakeScreen(210, 3)
        New(hifuu_water_bomb, self)
        self.nextspell = self.water_duration + 60
        self.protect = self.water_duration + 60
    else
        -- 莲子高速bomb
        PlaySound('nep00', 0.8)
        New(player_spell_mask, 0, 0, 0, 15, 135, 30)
        self._playersys:unregKeys("slow")
        self.bladeing         = true
        self.blade_timer      = self.blade_duration
        self.blade_hit_enemy  = {}
        self.blade_hit_bullet = {}

        self.nextspell        = self.blade_duration + 60 -- 冷却
        self.protect          = self.blade_duration + 60 -- 全程无敌
    end
end

-------------------------------------------------------
function hifuu_player:render()
    for i = 1, 4 do
        if self.sp[i] and self.sp[i][3] > 0.5 then
            if self.slow == 1 then
                RenderAnimation('hifuu_support_merry', self.timer, self.supportx + self.sp[i][1],
                    self.supporty + self.sp[i][2], 0, 0.3)
            else
                RenderAnimation('hifuu_support_renko', self.timer, self.supportx + self.sp[i][1],
                    self.supporty + self.sp[i][2], self.timer, 0.3)
            end
        end
    end

    if self.fire == 1 and self.slow == 1 and self.nextspell <= 0 then
        local timer = self.timer * 8 -- 动画速度
        local angle = 90   -- 固定向上
        for i = 1, 2 do
            local x = self.x + (i == 1 and -10 or 10)
            local y = self.y + 20

            local tex = 'hifuu_laser_heartbeat'
            -- 左边（i==1）晚半个周期（256的一半=128）
            local laser_timer = timer + (i == 1 and 128 or 0)
            local len = self.offset[i]
            if len < 600 then
                lib.CreateLaser(x, y, angle, 50, laser_timer, Color(0x80FF40FF), len, tex)
            else
                lib.CreateLaser(x, y, angle, 50, laser_timer, Color(0xF0FFFFFF), 600, tex)
            end
            -- 激光起点发光
            Render('hifuu_laser_light', x, y, self.timer * 5, 1 + 0.4 * sin(self.timer * 45 + i * 90))
            -- 激光末端（击中点）发光，遮住断开处
            if len < 600 then
                local ex = x + len * cos(angle)
                local ey = y + len * sin(angle)
                Render('hifuu_laser_light', ex, ey, -self.timer * 5, 1.2 + 0.4 * sin(self.timer * 45 + i * 90))
            end
        end
    end

    player_class.render(self)
end

-------------------------------------------------------
function hifuu_player:frame()
    if self.bladeing then
        self.__slow_flag = false
        self.slowlock = false
        self.hspeed = self.blade_hspeed
    end
    player_class.frame(self)

    if self.slow == 1 then
        -- 低速
        if self.into_slow == 0 then
            New(hifuu_switch_ef, self, 3, 20, 'in', 240, 240, 0)
        end
        self.into_slow = 1
        for i = 1, 24 do self.imgs[i] = 'hifuu_player_merry' .. i end
    else
        -- 高速
        self.into_slow = 0
        for i = 1, 24 do self.imgs[i] = 'hifuu_player_renko' .. i end
    end

    --莲子高速bomb
    if self.bladeing then
        -- 锁死高速状态
        self.slow = 0
        -- 顶住无敌（防止被 updateVar 减到 0）
        self.protect = max(self.protect, 2)
        -- 提高移动速度（玩家自己控制方向去撞）
        self.hspeed = self.blade_hspeed

        -- 每2帧生成一个残影
        if self.timer % 2 == 0 then
            New(hifuu_blade_shadow, self)
        end

        -- 记录撞到的敌人（考虑敌人碰撞盒 o.a）
        for i, o in ObjList(GROUP_ENEMY) do
            if o.colli and Dist(self, o) < self.blade_range + o.a then
                if not self.blade_hit_enemy[o] then
                    PlaySound('slash', 0.8)
                    self.blade_hit_enemy[o] = true
                    -- 创建光环标记
                    New(hifuu_blade_aura, o)
                    if not o._bosssys then
                        -- 暂停非boss类敌人移动
                        if not o._blade_frozen then
                            o._blade_frozen = true
                            -- 保存原速度
                            o._blade_saved_vx = o.vx
                            o._blade_saved_vy = o.vy
                            -- 清零速度
                            SetV(o, 0, 0, false)
                        end
                    end
                end
            end
        end
        for i, o in ObjList(GROUP_NONTJT) do
            if o.colli and Dist(self, o) < self.blade_range + o.a then
                if not self.blade_hit_enemy[o] then
                    PlaySound('slash', 0.8)
                    self.blade_hit_enemy[o] = true
                    -- 创建光环标记
                    New(hifuu_blade_aura, o)
                    if not o._bosssys then
                        -- 暂停非boss类敌人移动
                        if not o._blade_frozen then
                            o._blade_frozen = true
                            -- 保存原速度
                            o._blade_saved_vx = o.vx
                            o._blade_saved_vy = o.vy
                            -- 清零速度
                            SetV(o, 0, 0, false)
                        end
                    end
                end
            end
        end

        -- 记录撞到的可消弹（考虑子弹大小 o.a），标记避免重复
        for i, o in ObjList(GROUP_ENEMY_BULLET) do
            if not o._blade_marked and Dist(self, o) < self.blade_range + o.a then
                PlaySound('slash', 0.8)
                o._blade_marked = true
                table.insert(self.blade_hit_bullet, o)

                -- 立刻改变子弹状态
                o.group = GROUP_GHOST -- 改到幽灵组，不再与玩家碰撞
                o.colli = false -- 关闭碰撞
                SetV(o, 0, 0, false) -- 停止运动（速度=0，加速度=0）

                -- 清除 task（如果子弹有协程逻辑）
                if o._task then
                    task.Clear(o)
                end

                -- 变深红色
                if o.img then
                    -- 防止高光污染
                    local base_type = lib.get_bullet_base_type(o.img)

                    local dark_type = bullet_light_to_dark[base_type]


                    if dark_type then
                        -- 高光子弹：先换成暗版本，再设置高光和颜色
                        local index_suffix = string.match(o.img, "%d+$") or ""

                        local new_img = dark_type

                        ChangeBulletImage(o, new_img, index_suffix)

                        _object.set_color(o, "mul+add", 255, 50, 50, 50)
                    else
                        -- 普通子弹
                        local blend_mode = o._blend or ''
                        _object.set_color(o, blend_mode, 255, 50, 50, 50)
                    end
                end
            end
        end

        self.blade_timer = self.blade_timer - 1
        if self.blade_timer <= 0 then
            lib.blade_finish(self)
        end
    end
end

-------------------------------------------------------
function lib.blade_finish(p)
    p.bladeing = false
    p.hspeed = 4.5
    p._playersys:regKeys("slow")
    -- 统计并消除撞到的可消弹
    local bullet_count = 0
    for _, b in ipairs(p.blade_hit_bullet) do
        if IsValid(b) then
            bullet_count = bullet_count + 1
            b._blade_marked = nil
            Del(b) -- 消弹（如需特效可在此 New 一个特效对象）
        end
    end

    -- 伤害 = 基础 + 子弹加成，带上限
    local dmg = p.blade_base_dmg + bullet_count * p.blade_per_bullet
    dmg = min(dmg, p.blade_dmg_cap)

    -- 只给伤害，不 Kill
    for o, _ in pairs(p.blade_hit_enemy) do
        if IsValid(o) and o.colli then
            Damage(o, dmg)
            if IsValid(o.blade_aura) then
                Del(o.blade_aura)
                o.blade_aura = nil
            end
            if not o._bosssys then
                -- 恢复普通敌人移动
                if o._blade_frozen then
                    o._blade_frozen = false
                    -- 恢复速度
                    SetV(o, o._blade_saved_vx or 0, o._blade_saved_vy or 0, true)
                    o._blade_saved_vx = nil
                    o._blade_saved_vy = nil
                end
            end
        end
    end

    -- 结算表现：震屏
    misc.ShakeScreen(20, 6)
    New(bullet_killer, p.x, p.y)
    PlaySound('slash', 0.8)

    p.blade_hit_enemy = {}
    p.blade_hit_bullet = {}
end

-------------------------------------------------------
hifuu_sp_ef1 = Class(object)
function hifuu_sp_ef1:init(img, x, y, v, angle, target, trail, dmg, t, player)
    self.killflag = true
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_PLAYER_BULLET
    self.img = img
    self.vscale = 1.2
    self.hscale = 1.2
    self.a = self.a * 1.2
    self.b = self.b * 1.2
    self.x = x
    self.y = y
    self.rot = angle
    self.angle = angle
    self.v = v
    self.target = target
    self.trail = trail
    self.dmg = dmg
    self.DMG = dmg
    self.bound = false
    self.tflag = t
    self.player = player
end

function hifuu_sp_ef1:frame()
    if BoxCheck(self, -192, 192, -224, 224) then self.inscreen = true end
    if self.timer < 150 + self.tflag then
        self.rot = self.angle - 4 * self.timer - 90
        self.x = self.timer * 1 * cos(self.rot + 90) + self.player.x
        self.y = self.timer * 1 * sin(self.rot + 90) + self.player.y
    end
    player_class.findtarget(self)
    if self.timer > 150 + self.tflag then
        self.killflag = false
        self.dmg = 35
        if IsValid(self.target) and self.target.colli then
            local a = math.mod(Angle(self, self.target) - self.rot + 720, 360)
            if a > 180 then a = a - 360 end
            local da = self.trail / (Dist(self, self.target) + 1)
            if da >= abs(a) then
                self.rot = Angle(self, self.target)
            else
                self.rot = self.rot + sign(a) * da
            end
        end
        self.vx = 8 * cos(self.rot)
        self.vy = 8 * sin(self.rot)
        if self.inscreen then
            if self.x > 192 then
                self.x = 192
                self.vx = 0
                self.vy = 0
            end
            if self.x < -192 then
                self.x = -192
                self.vx = 0
                self.vy = 0
            end
            if self.y > 224 then
                self.y = 224
                self.vx = 0
                self.vy = 0
            end
            if self.y < -224 then
                self.y = -224
                self.vx = 0
                self.vy = 0
            end
        end
    end
    if self.timer > 230 then
        self.killflag = true
        self.dmg = 0.4 * self.DMG
        self.a = 2 * self.a
        self.b = 2 * self.b
        self.vscale = (self.timer - 230) * 0.5 + 1
        self.hscale = (self.timer - 230) * 0.5 + 1
    end
    if self.timer > 240 then
        Kill(self)
    end
    New(bomb_bullet_killer, self.x, self.y, self.a * 1.5, self.b * 1.5, false)
end

function hifuu_sp_ef1:kill()
    misc.ShakeScreen(5, 5)
    PlaySound('explode', 0.3)
    New(bubble, 'parimg12', self.x, self.y, 30, 4, 6, Color(0xFFFFFFFF), Color(0x00FFFFFF), LAYER_ENEMY_BULLET_EF, '')
    local a = ran:Float(0, 360)
    for i = 1, 12 do
        New(hifuu_sp_ef2, self.x, self.y, ran:Float(4, 6), a + i * 30, 2, ran:Int(1, 3))
    end
    self.vscale = 2
    self.hscale = 2
    --	misc.KeepParticle(self)
end

function hifuu_sp_ef1:del()
    PlaySound('explode', 0.3)
    New(bubble, 'parimg12', self.x, self.y, 30, 4, 6, Color(0xFFFFFFFF), Color(0x00FFFFFF), LAYER_ENEMY_BULLET_EF, '')
    --	for i=1,4 do
    --		New(hifuu_sp_ef2,16,16,self.x,self.y,3,360/16*i,0.25,4,30)
    --	end
    misc.KeepParticle(self)
    self.vscale = 6
    self.hscale = 6
end

-------------------------------------------------------
hifuu_sp_ef2 = Class(object)

function hifuu_sp_ef2:init(x, y, v, angle, scale, index)
    self.img = 'hifuu_bomb_ef'
    self.group = GROUP_GHOST
    self.layer = LAYER_PLAYER_BULLET
    self.colli = false
    self.x = x
    self.y = y
    self.rot = angle
    self.vx = v * cos(angle)
    self.vy = v * sin(angle)
    self.dmg = dmg
    self.hide = false
    self.scale = scale
    self.hscale = scale
    self.vscale = scale
    self.rbg = { { 255, 0, 0 }, { 0, 255, 0 }, { 0, 0, 255 } }
    self.index = index
    --	ParticleSetEmission(self,10)
end

function hifuu_sp_ef2:frame()
    self.vscale = self.scale * (1 - self.timer / 60)
    self.hscale = self.scale * (1 - self.timer / 60)
    if self.timer >= 30 then Del(self) end
end

function hifuu_sp_ef2:render()
    SetImageState(self.img, 'mul+add',
        Color(255 - 255 * self.timer / 30, self.rbg[self.index][1], self.rbg[self.index][2], self.rbg[self.index][3]))
    Render(self.img, self.x, self.y)
    SetImageState(self.img, 'mul+add', Color(255, 255, 255, 255))
end

-------------------------------------------------------
hifuu_bullet_renko_main = Class(player_bullet_straight)

function hifuu_bullet_renko_main:kill()
    New(hifuu_bullet_renko_main_ef, self.x, self.y, self.rot + 180)
end

-------------------------------------------------------
hifuu_bullet_renko_main_ef = Class(object)

function hifuu_bullet_renko_main_ef:init(x, y)
    self.x = x
    self.y = y
    self.rot = 90
    self.img = 'hifuu_bullet_renko_main_ef'
    self.layer = LAYER_PLAYER_BULLET + 50
    self.group = GROUP_GHOST
    self.vy = 2.25
end

function hifuu_bullet_renko_main_ef:frame()
    if self.timer == 15 then
        self.y = 600
        Del(self)
    end
end

-------------------------------------------------------
hifuu_bullet_orange = Class(player_bullet_straight)

function hifuu_bullet_orange:kill()
    New(hifuu_bullet_orange_ef, self.x, self.y, self.rot + 180 + ran:Float(-15, 15))
    New(hifuu_bullet_orange_ef2, self.x, self.y)
end

-------------------------------------------------------
hifuu_bullet_renko_sub = Class(player_bullet_straight)
function hifuu_bullet_renko_sub:init(img, x, y, v, angle, dmg)
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_PLAYER_BULLET
    self.img = img
    self.x = x
    self.y = y
    self.rot = angle
    self.v = v
    self.vx = v * cos(angle)
    self.vy = v * sin(angle)
    self.dmg = dmg
end

function hifuu_bullet_renko_sub:kill()
    New(hifuu_bullet_renko_sub_ef, self.x, self.y, self.rot)
end

-------------------------------------------------------
hifuu_bullet_renko_sub_ef = Class(object)

function hifuu_bullet_renko_sub_ef:init(x, y, rot)
    self.x = x
    self.y = y
    self.rot = rot
    self.img = 'hifuu_bullet_renko_sub_ef'
    self.layer = LAYER_PLAYER_BULLET + 50
    self.group = GROUP_GHOST
    self.vx = 1 * cos(rot)
    self.vy = 1 * sin(rot)
end

function hifuu_bullet_renko_sub_ef:frame()
    if self.timer > 14 then Del(self) end
end

-------------------------------------------------------
hifuu_sp_ef = Class(player_bullet_trail)

function hifuu_sp_ef:kill()
    PlaySound('explode', 0.3)
    New(bubble, 'parimg12', self.x, self.y, 30, 4, 6, Color(0xFFFFFFFF), Color(0x00FFFFFF), LAYER_ENEMY_BULLET_EF, '')
    for i = 1, 16 do
        New(hifuu_sp_ef2, 16, 16, self.x, self.y, 3, 360 / 16 * i, 0.25, 4, 30)
    end
    misc.KeepParticle(self)
end

function hifuu_sp_ef:del()
    misc.KeepParticle(self)
end

-------------------------------------------------------
hifuu_bullet_ef = Class(object)

function hifuu_bullet_ef:init(x, y, rot)
    self.x = x
    self.y = y
    self.rot = rot
    self.img = 'hifuu_bullet_ef'
    self.layer = LAYER_PLAYER_BULLET + 50
    self.group = GROUP_GHOST
end

function hifuu_bullet_ef:frame()
    if self.timer == 4 then ParticleStop(self) end
    if self.timer == 30 then Del(self) end
end

-------------------------------------------------------
hifuu_bullet_orange_ef = Class(object)

function hifuu_bullet_orange_ef:init(x, y, rot)
    self.x = x
    self.y = y + 32
    self.rot = rot
    self.img = 'hifuu_bullet_orange_ef'
    self.layer = LAYER_PLAYER_BULLET + 50
    self.group = GROUP_GHOST
    self.vy = 2
    self.hscale = ran:Float(1.4, 1.6)
end

function hifuu_bullet_orange_ef:frame()
    if self.timer > 15 then
        self.x = 600
        Del(self)
    end
end

function hifuu_bullet_orange_ef:render()
    SetImageState(self.img, 'mul+add', Color(255 - 255 * self.timer / 16, 255, 255, 255))
    object.render(self)
end

--修改击中效果
-------------------------------------------------------
hifuu_bullet_orange_ef2 = Class(object)

function hifuu_bullet_orange_ef2:init(x, y)
    self.x = x
    self.y = y + 32
    self.rot = -90 + ran:Float(-10, 10)
    self.img = 'hifuu_bullet_orange_ef2'
    self.layer = LAYER_PLAYER_BULLET + 50
    self.group = GROUP_GHOST
    self.hscale = ran:Float(1.5, 1.8)
    self.vscale = 1.5
end

function hifuu_bullet_orange_ef2:frame()
    if self.timer >= 9 then
        self.x = 600
        Del(self)
    end
end

-------------------------------------------------------

hifuu_kekkai = Class(object)

function hifuu_kekkai:init(x, y, dmg, dr, n, t)
    self.x = x
    self.y = y
    self.dmg = dmg
    SetImageState('hifuu_kekkai', 'mul+add', Color(0x804040FF))
    self.killflag = true
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_PLAYER_BULLET
    self.r = 0
    self.a = 0
    self.b = 0
    self.dr = dr
    self.ds = dr / 256
    self.n = 0
    self.mute = true
    self.list = {}
    task.New(self, function()
        for i = 1, n do
            self.list[i] = { scale = 0, rot = 0 }
            self.n = self.n + 1
            task.Wait(t)
        end
        self.dmg = 0
        PlaySound('slash', 1.0)
        --		New(bullet_killer,self.x,self.y)
        for i = 128, 0, -4 do
            SetImageState('hifuu_kekkai', 'mul+add', Color(0x004040FF) + i * Color(0x01000000))
            task.Wait(1)
        end
        Del(self)
    end)
end

function hifuu_kekkai:frame()
    task.Do(self)
    if self.timer % 6 == 0 then self.mute = false else self.mute = true end
    self.r = self.r + self.dr
    self.a = self.r
    self.b = self.r
    for i = 1, self.n do
        self.list[i].scale = self.list[i].scale + self.ds
        self.list[i].rot = self.list[i].rot + (-1) ^ i
    end
    New(bomb_bullet_killer, self.x, self.y, self.a / 1.25, self.b / 1.25, false)
end

function hifuu_kekkai:render()
    for i = 1, self.n do
        Render('hifuu_kekkai', self.x, self.y, self.list[i].rot, self.list[i].scale)
    end
end

-------------------------------------------------------
--- 梅莉低速bomb：水面涟漪
--- 逻辑与表现分离：
---   hifuu_water_bomb    —— 主控制器，负责三阶段节奏、范围伤害、消弹
---   hifuu_water_capture —— 低layer，render里开始捕获画面
---   hifuu_water_apply   —— 高layer，render里结束捕获并应用水面shader
--- 捕获范围：LAYER_ENEMY 之前 到 LAYER_ENEMY_BULLET_EF 之后（含自机，全夹方案）
-------------------------------------------------------

-- 夹层：起点（比背景层更靠前，确保背景也被捕获进RT，否则水面范围外会变黑）
local WATER_CAPTURE_LAYER = LAYER_BG - 10
-- 夹层：终点（比子弹特效层更靠后，确保全部被捕获）
local WATER_APPLY_LAYER   = LAYER_ENEMY_BULLET_EF + 10

hifuu_water_bomb          = Class(object)

function hifuu_water_bomb:init(player)
    self.player       = player
    -- 水面中心：bomb启动时固定的自机坐标
    self.cx           = player.x
    self.cy           = player.y
    -- 涟漪中心：实时跟随玩家（初始与水面中心一致）
    self.rx           = player.x
    self.ry           = player.y

    -- 参数（从玩家配置读取，带默认值）
    self.duration     = player.water_duration or 180
    self.expand_time  = player.water_expand_time or 45
    self.fade_time    = player.water_fade_time or 45
    self.dmg          = player.water_dmg or 2
    self.max_radius   = player.water_max_radius or 220

    -- 当前阶段参数（每帧更新，传给shader和伤害逻辑）
    self.expandRadius = 0 -- 0-1
    self.alpha        = 0 -- 0-1

    -- 伤害用碰撞体（照抄灵梦结界模式）
    self.killflag     = true
    self.group        = GROUP_PLAYER_BULLET
    self.layer        = LAYER_PLAYER_BULLET
    self.a            = 0
    self.b            = 0
    self.colli        = true

    -- 创建夹层渲染对象
    self.capture_obj  = New(hifuu_water_capture)
    self.apply_obj    = New(hifuu_water_apply, self)
end

function hifuu_water_bomb:frame()
    local t = self.timer

    -- 涟漪中心跟随玩家当前位置
    if IsValid(self.player) then
        self.rx = self.player.x
        self.ry = self.player.y
    end

    -- 三阶段节奏
    if t < self.expand_time then
        -- 阶段1：展开（带流线扰动，shader里处理）
        self.expandRadius = t / self.expand_time
        self.alpha = self.expandRadius
    elseif t < self.duration - self.fade_time then
        -- 阶段2：涟漪持续
        self.expandRadius = 1.0
        self.alpha = 1.0
    elseif t < self.duration then
        -- 阶段3：淡出
        self.expandRadius = 1.0
        self.alpha = 1.0 - (t - (self.duration - self.fade_time)) / self.fade_time
    else
        -- 结束：用最大半径消弹一次（bomb期间不消弹，保留水面扭曲的观赏效果）
        New(bomb_bullet_killer, self.x, self.y, self.max_radius, self.max_radius, false)
        Del(self)
        return
    end

    -- 伤害范围：跟随涟漪中心（玩家），半径随展开进度扩大
    local r = self.max_radius * self.expandRadius
    self.x = self.rx
    self.y = self.ry
    self.a = r
    self.b = r
end

-- 主控制器不自绘，视觉全部由夹层对象负责
function hifuu_water_bomb:render() end

-- 造成伤害后不消失（持续bomb），靠timer结束
function hifuu_water_bomb:del()
    if IsValid(self.capture_obj) then Del(self.capture_obj) end
    if IsValid(self.apply_obj) then Del(self.apply_obj) end
end

function hifuu_water_bomb:kill()
    if IsValid(self.capture_obj) then Del(self.capture_obj) end
    if IsValid(self.apply_obj) then Del(self.apply_obj) end
end

-------------------------------------------------------
-- 夹层起点：开始捕获画面
hifuu_water_capture = Class(object)

function hifuu_water_capture:init()
    self.group = GROUP_GHOST
    self.layer = WATER_CAPTURE_LAYER
    self.bound = false
end

function hifuu_water_capture:frame() end

function hifuu_water_capture:render()
    water.beginCapture()
end

-------------------------------------------------------
-- 夹层终点：结束捕获并应用水面shader
hifuu_water_apply = Class(object)

function hifuu_water_apply:init(bomb)
    self.bomb  = bomb
    self.group = GROUP_GHOST
    self.layer = WATER_APPLY_LAYER
    self.bound = false
end

function hifuu_water_apply:frame() end

function hifuu_water_apply:render()
    local b = self.bomb
    if not IsValid(b) then
        -- bomb已失效但仍在捕获状态：强制收尾，避免渲染栈失衡
        if water.isCapturing() then
            water.apply(0, 0, 0, 0, 0, 0, 0)
        end
        return
    end
    -- timer换算成秒（动画计时）
    water.apply(
        b.cx, b.cy, -- 水面中心（固定）
        b.rx, b.ry, -- 涟漪中心（跟随玩家）
        b.expandRadius,
        b.alpha,
        b.timer / 60.0
    )
end

hifuu_bullet_heart = Class(player_bullet_trail)
function hifuu_bullet_heart:init(img, x, y, v, angle, target, trail, dmg)
    self.group = GROUP_PLAYER_BULLET
    self.layer = LAYER_PLAYER_BULLET
    self.img = img
    self.x = x
    self.y = y
    self.rot = angle
    self.v = v
    self.target = target
    self.trail = trail
    self.dmg = dmg
end

function hifuu_bullet_heart:frame()
    player_class.findtarget(self)
    if IsValid(self.target) and self.target.colli then
        local a = math.mod(Angle(self, self.target) - self.rot + 720, 360)
        if a > 180 then a = a - 360 end
        local da = self.trail / (Dist(self, self.target) + 1)
        if da >= abs(a) then
            self.rot = Angle(self, self.target)
        else
            self.rot = self.rot + sign(a) * da
        end
    end
    self.vx = self.v * cos(self.rot)
    self.vy = self.v * sin(self.rot)
end

function hifuu_bullet_heart:kill()
    New(hifuu_bullet_heart_ef, self.x, self.y, self.rot)
end

-------------------------------------------------------
hifuu_bullet_heart_ef = Class(object)

function hifuu_bullet_heart_ef:init(x, y, rot)
    self.x = x
    self.y = y
    self.rot = rot
    self.img = 'hifuu_bullet_heart_ef'
    self.layer = LAYER_PLAYER_BULLET + 50
    self.group = GROUP_GHOST
    self.vx = 1 * cos(rot)
    self.vy = 1 * sin(rot)
end

function hifuu_bullet_heart_ef:frame()
    if self.timer > 14 then Del(self) end
end

hifuu_switch_ef = Class(object)
function hifuu_switch_ef:init(player, radius, t, type, r, g, b)
    self.x = player.x
    self.y = player.y
    self.r = r
    self.g = g
    self.b = b
    self.t = t
    self.radius = radius
    self.img = 'hifuu_switch_ef'
    self.group = GROUP_GHOST
    self.layer = LAYER_PLAYER + 10
    self.hscale = radius
    self.vscale = radius
    task.New(self, function()
        PlaySound('ophide', 1.0)
        if type == 'in' then
            self.hscale = radius
            self.vscale = radius
            for i = 1, self.t do
                self.hscale = self.radius - self.radius * self.timer / self.t
                self.vscale = self.radius - self.radius * self.timer / self.t
                self.x = player.x
                self.y = player.y
                task.Wait(1)
            end
        else
            self.hscale = 0
            self.vscale = 0
            for i = 1, self.t do
                self.hscale = self.radius * self.timer / self.t
                self.vscale = self.radius * self.timer / self.t
                self.x = player.x
                self.y = player.y
                task.Wait(1)
            end
        end
        Del(self)
    end)
end

function hifuu_switch_ef:frame()
    task.Do(self)
end

function hifuu_switch_ef:render()
    SetImageState(self.img, 'mul+alpha', Color(255 - 255 * self.timer / self.t, self.r, self.g, self.b))
    object.render(self)
end

function lib.IsInLaser(x0, y0, a, unit, w)
    local a1 = a - Angle(x0, y0, unit.x, unit.y)
    if a % 180 == 90 then
        if abs(unit.x - x0) < ((unit.a + unit.b + w) / 2) and cos(a1) >= 0 then
            return true
        else
            return false
        end
    else
        local A = tan(a)
        local C = y0 - A * x0
        if abs(A * unit.x - unit.y + C) / hypot(A, 1) < ((unit.a + unit.b + w) / 2) and cos(a1) >= 0 then
            return true
        else
            return false
        end
    end
end

function lib.CreateLaser(x, y, a, w, t, c, offset, tex)
    local width = w / 2
    local n = int(offset / 256)
    local length = t % 256
    local endl = int(offset - n * 256)

    local w_x = width * cos(a)
    local w_y = width * sin(a)
    local blend = 'mul+alpha'

    for i = 1, n do
        local vx1 = x + (length + 256 * (i - 1)) * cos(a)
        local vy1 = y + (length + 256 * (i - 1)) * sin(a)
        local vx2 = x + 256 * i * cos(a)
        local vy2 = y + 256 * i * sin(a)
        local vx3 = x + 256 * (i - 1) * cos(a)
        local vy3 = y + 256 * (i - 1) * sin(a)
        RenderTexture(
            tex, blend,
            { vx1 - w_y, vy1 + w_x, 0.5, 0, 0, c },
            { vx2 - w_y, vy2 + w_x, 0.5, 256 - length, 0, c },
            { vx2 + w_y, vy2 - w_x, 0.5, 256 - length, 50, c },
            { vx1 + w_y, vy1 - w_x, 0.5, 0, 50, c })
        RenderTexture(
            tex, blend,
            { vx3 - w_y, vy3 + w_x, 0.5, 256 - length, 0, c },
            { vx1 - w_y, vy1 + w_x, 0.5, 256, 0, c },
            { vx1 + w_y, vy1 - w_x, 0.5, 256, 50, c },
            { vx3 + w_y, vy3 - w_x, 0.5, 256 - length, 50, c })
    end

    local vx2 = x + (endl + 256 * n) * cos(a)
    local vy2 = y + (endl + 256 * n) * sin(a)
    local vx3 = x + 256 * n * cos(a)
    local vy3 = y + 256 * n * sin(a)
    if length <= endl then
        local vx1 = x + (length + 256 * n) * cos(a)
        local vy1 = y + (length + 256 * n) * sin(a)
        RenderTexture(
            tex, blend,
            { vx1 - w_y, vy1 + w_x, 0.5, 0, 0, c },
            { vx2 - w_y, vy2 + w_x, 0.5, endl - length, 0, c },
            { vx2 + w_y, vy2 - w_x, 0.5, endl - length, 50, c },
            { vx1 + w_y, vy1 - w_x, 0.5, 0, 50, c })
        RenderTexture(
            tex, blend,
            { vx3 - w_y, vy3 + w_x, 0.5, 256 - length, 0, c },
            { vx1 - w_y, vy1 + w_x, 0.5, 256, 0, c },
            { vx1 + w_y, vy1 - w_x, 0.5, 256, 50, c },
            { vx3 + w_y, vy3 - w_x, 0.5, 256 - length, 50, c })
    else
        RenderTexture(
            tex, blend,
            { vx3 - w_y, vy3 + w_x, 0.5, 256 - length, 0, c },
            { vx2 - w_y, vy2 + w_x, 0.5, endl + 256 - length, 0, c },
            { vx2 + w_y, vy2 - w_x, 0.5, endl + 256 - length, 50, c },
            { vx3 + w_y, vy3 - w_x, 0.5, 256 - length, 50, c })
    end
end

merry_laser_hit = Class(object)

function merry_laser_hit:init(x, y)
    self.x = x
    self.y = y
    self.group = GROUP_GHOST
    self.layer = LAYER_PLAYER_BULLET + 60
    self.img = 'merry_hit'
end

function merry_laser_hit:frame()
    if self.timer == 10 then
        ParticleStop(self)
    end
    if self.timer == 20 then Del(self) end
end

--- 残影特效
hifuu_blade_shadow = Class(object)

function hifuu_blade_shadow:init(player)
    self.x = player.x
    self.y = player.y
    self.layer = LAYER_PLAYER - 1 -- 在玩家下方
    self.group = GROUP_GHOST
    self.rot = player.rot
    self.hscale = player.hscale or 1
    self.vscale = player.vscale or 1
    -- 复制当前的图片
    self.img = player.img
    self.timer = 0
    self.max_life = 20 -- 残影持续帧数
end

function hifuu_blade_shadow:frame()
    if self.timer >= self.max_life then
        Del(self)
    end
end

function hifuu_blade_shadow:render()
    -- 淡出效果
    local alpha = 255 * (1 - self.timer / self.max_life)
    SetImageState(self.img, 'mul+alpha', Color(alpha, 70, 0, 0)) -- 黑白滤镜
    Render(self.img, self.x, self.y, self.rot, self.hscale, self.vscale)
end

--- 光环特效
hifuu_blade_aura = Class(object)

function hifuu_blade_aura:init(target)
    self.target = target
    self.x = target.x
    self.y = target.y
    self.layer = target.layer + 5 -- 在 enemy 上方
    self.group = GROUP_GHOST
    self.img = 'hifuu_blade_aura'
    self.hscale = 0.5
    self.vscale = 0.5
    target.blade_aura = self
end

function hifuu_blade_aura:frame()
    if not IsValid(self.target) then
        Del(self)
        return
    end
    -- 跟随 enemy 位置
    self.x = self.target.x
    self.y = self.target.y
end

function hifuu_blade_aura:render()
    object.render(self)
    local alpha = 128 + 15 * sin(self.timer * 8)
    SetAnimationState(self.img, 'mul+alpha', Color(alpha, 50, 50, 50))
end

-- 辅助函数：从完整图片名提取基础类型（去掉数字后缀）
function lib.get_bullet_base_type(img_name)
    -- 图片名格式：ball_mid_b1, ball_huge12, water_drop3 等
    -- 提取非数字部分作为基础类型
    return string.match(img_name, "^([^0-9]+)")
end

-- 辅助函数：判断是否是高光子弹（精确匹配基础类型）
function lib.is_light_bullet(img_name)
    local base_type = get_bullet_base_type(img_name)
    return bullet_light_to_dark[base_type] ~= nil
end

AddPlayerToPlayerList('Hifuu Club', 'hifuu_player', 'Hifuu')
