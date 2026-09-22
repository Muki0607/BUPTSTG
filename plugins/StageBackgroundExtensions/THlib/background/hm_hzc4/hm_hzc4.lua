HM_hzc4_background = Class(object)
hm_bg_hzc4 = false
--
----辉针城四面背景
----使用或修改时请注明原作者。
----素材来源于原作拆包
----感谢莉莉姐和青山老爷的指点
function HM_hzc4_background:init()
    background.init(self, false)

    self.m = 8
    self.imgs = {}
    self.angle = 0
    --rescore
    LoadImageFromFile('bg1', 'THlib/background/hm_hzc4/bg1.png')
    LoadImageFromFile('bg2', 'THlib/background/hm_hzc4/bg2.png')
    LoadImageFromFile('bg3', 'THlib/background/hm_hzc4/bg3.png')
    LoadImageFromFile('bg4', 'THlib/background/hm_hzc4/bg4.png')
    LoadImageFromFile('bg5', 'THlib/background/hm_hzc4/bg5.png')
    LoadImageFromFile('bg6', 'THlib/background/hm_hzc4/bg6.png')
    LoadImageGroup('hm_hzc3_', 'bg3', 0, 0, 128, 512 / self.m, 1, self.m, 0, 0)
    for i = 1, self.m do self.imgs[i] = 'hm_hzc3_' .. i end
    --
    self.z = 4
    Set3D('eye', 0, 12.5, 0)
    Set3D('at', 0, 2, 2.5)
    Set3D('up', 0, 1, 0)
    Set3D('z', 0.1, 24)
    Set3D('fovy', 0.7)
    Set3D('fog', 7, 20, Color(112, 128, 128, 200))
    --
    self.n = 12
    --
    SetImageState('bg1', 'mul+alpha', Color(200, 255, 255, 255))
    SetImageState('bg2', 'mul+alpha', Color(100, 255, 255, 255))
    SetImageState('bg3', 'mul+alpha', Color(200, 255, 255, 255))
    --
    --[[ 钻出隧道 --------------------------------------------------
        世界坐标约定：y 轴是隧道轴向（前后），z 轴朝上，x 轴是左右。
        原摄像机的视线几乎沿着 -y，屏幕上方向约等于 +z。
        外部把 self.flag 置为 true（例如在 stage 脚本里
        lstg.tmpvar.bg.flag = true）之后：
        1. 隧道不再重复（多圈）渲染，并在 exit_duration 帧内持续移动摄像机，
		先沿着隧道轴向（-y）飞出隧道口，再升到地面上方，同时视线连续
		低头到垂直向下，做出钻出隧道、从空中俯瞰大地的效果；
        2. 飞出后彻底不画隧道，改为渲染 z = ground_z 的 bg5 地面和 bg4 雾气，
		地面是 xy 平面并沿 y 方向铺瓦片循环滚动，做出不断向前飞行的效果。
    ]]
    self.flag = false        -- 由外部置 true 触发
    -- 出隧道和抬升共用一条时间轴：move_timer 从 0 走到两段时长之和，
    -- 缓动曲线只做一条，两段之间就不会出现速度归零的停顿
    self.move_timer = 0
    self.exit_duration = 180 -- 第一段（钻出隧道）的帧数
    -- 第二段取 120 帧，是为了让两段在接缝处的空间速度正好对上：
    -- 两段都线性于总进度 P，速度 ∝ 距离 / 该段占 P 的比例。第一段末尾
    -- |d(eye)/ds| = sqrt(52.5^2 + 50^2) ≈ 72.5（y 走 52.5、z 走 10 且末尾最陡），
    -- 第二段是纯 z 位移 40；令 72.5/Pb = 40/(1-Pb) 得 Pb≈0.644，对应帧数比 180:120。
    -- 所以接缝处不会有速度突变，中间也不会像两段各自缓动那样停下来。
    -- 改 rise_eye_z 的话这个比例要跟着重算。
    self.rise_duration = 120 -- 第二段（抬升）的帧数
    self.exit_s = 0          -- 第一段进度 0~1，frame 算好后给 render 用
    self.rise_s = 0          -- 第二段进度 0~1
    -- 摄像机：起点和 init 里的 eye/at 完全一致，终点在地面正上方
    self.exit_eye0 = { 0, 12.5, 0 }
    self.exit_eye1 = { 0, -40, 10 }
    -- 视线在 yz 平面内的角度（度）：-76.6 是原来的朝向，-180 是垂直向下
    self.exit_ang0 = -76.6
    self.exit_ang1 = -180
    self.exit_at_dist = 10.79 -- eye 到 at 的距离，沿用原来的值
    -- 抬升：出隧道之后继续把机位抬高，离开地面更远，同时雾气逐渐变浓
    self.rise_eye_z = 50      -- 抬升终点高度（地面 z=-10，即离地 60）
    -- 地面（bg5）：z = ground_z 的 xy 平面，沿 y 方向铺瓦片循环
    self.ground_z = -10
    self.ground_tile = 32
    -- 雾气（bg4 云层）：贴着地面由低到高排列，越低的越浓、滚动越慢（视差）
    -- rise_alpha 是抬升到位后的浓度，抬升过程中由 alpha 渐变到它
    self.fog_layers = {
        { z = -7, alpha = 35, rise_alpha = 105, speed = 1.00, tile = 48 },
        { z = -4, alpha = 22, rise_alpha = 72,  speed = 1.30, tile = 48 },
        { z = -1, alpha = 14, rise_alpha = 46,  speed = 1.60, tile = 48 },
    }
    -- 小片雾（bg6）：抬升时围绕摄像机的一层层薄雾，让上升过程更有空气感。
    -- 这些雾片锚定在世界坐标的 z 网格上，所以机位一抬高，它们就会相对地面向下
    -- 掠过，"升上去"的感觉就是从这儿来的；水平方向再跟着 scroll 持续流动。
    -- gap 大于 tile 才会在片与片之间留出缝隙，看起来才是"一片片"而不是整片。
    self.mist = {
        tile = 22,    -- 每片雾的大小
        gap = 30,     -- 片与片的水平间隔
        layer_z = 11, -- 层与层的垂直间隔
        layers = 6,   -- 层数：从地面上方一直排到抬升终点之上
        alpha = 120,  -- 抬升到位时的浓度
    }
    -- 地面与雾气的循环滚动量（不断向前移动），改 scroll_speed 就是改前进速度
    self.scroll = 0
    self.scroll_speed = 0.10

	
    function self:render_tunnel()
        -- flag 置位之后不再重复（多圈）绘制隧道，这样才飞得出去
        local rep_max = self.flag and 0 or 2
        local R = 6
        local d = self.distance or 0
        -- 扩展绘制范围以支持循环，多绘制几圈覆盖视野
        for rep = -rep_max, rep_max do
            for i = 1, 12 do
                for j = 1, 12 do
                    Render4V('bg1',
                        R * cos(30 * i), -24 + R * (j + 1) + d + rep * R * 12, R * sin(30 * i),
                        R * cos(30 * i), -24 + R * j + d + rep * R * 12, R * sin(30 * i),
                        R * cos(30 * (i + 1)), -24 + R * j + d + rep * R * 12, R * sin(30 * (i + 1)),
                        R * cos(30 * (i + 1)), -24 + R * (j + 1) + d + rep * R * 12, R * sin(30 * (i + 1))
                    )
                end
            end
        end
        --
        local R = 5
        for rep = -rep_max, rep_max do
            for i = 1, 12 do
                for j = 1, 12 do
                    Render4V('bg2',
                        R * cos(self.angle + 30 * i), -20 + R * (j + 1) + d + rep * R * 12, R * sin(self.angle + 30 * i),
                        R * cos(self.angle + 30 * i), -20 + R * j + d + rep * R * 12, R * sin(self.angle + 30 * i),
                        R * cos(self.angle + 30 * (i + 1)), -20 + R * j + d + rep * R * 12,
                        R * sin(self.angle + 30 * (i + 1)),
                        R * cos(self.angle + 30 * (i + 1)), -20 + R * (j + 1) + d + rep * R * 12, R *
                        sin(self.angle + 30 * (i + 1))

                    )
                end
            end
        end
        ---bot
        for i = 1, self.m do SetImageState(self.imgs[i], 'mul+alpha', Color(180, 255, 255, 255)) end

        local R = 2.25
        local r = 2
        local a1 = 360 / self.n
        local a2 = a1 / self.m
        local a3 = self.timer * 0.3
        local a4 = self.timer * 0.1
        local k = 0.5
        local x = 0.5
        local y = 0.75
        local z = 1
        local dist = self.distance or 0
        for distrep = -rep_max, rep_max do
            local dy = dist + distrep * 6
            for n = 1, self.n do
                for m = 1, self.m do
                    Render4V(self.imgs[m],
                        x + r * cos(n * a1 + a2 * m + a3), y + k * cos(n * a1 + a2 * m + a3 + a4) + dy, z +
                        r * sin(n * a1 + a2 * m + a3),
                        x + R * cos(n * a1 + a2 * m + a3), y + k * cos(n * a1 + a2 * m + a3 + a4) + dy, z +
                        R * sin(n * a1 + a2 * m + a3),
                        x + R * cos(n * a1 + a2 * (m + 1) + a3), y + k * cos(n * a1 + a2 * (m + 1) + a3 + a4) + dy,
                        z + R * sin(n * a1 + a2 * (m + 1) + a3),
                        x + r * cos(n * a1 + a2 * (m + 1) + a3), y + k * cos(n * a1 + a2 * (m + 1) + a3 + a4) + dy,
                        z + r * sin(n * a1 + a2 * (m + 1) + a3)
                    )
                end
            end
        end
        local R = 2.75
        local r = 2.5
        for distrep = -rep_max, rep_max do
            local dy = dist + distrep * 6
            for n = 1, self.n do
                for m = 1, self.m do
                    Render4V(self.imgs[m],
                        x + r * cos(n * a1 + a2 * m + a3), y + k * cos(n * a1 + a2 * m + a3 + a4) + dy, z +
                        r * sin(n * a1 + a2 * m + a3),
                        x + R * cos(n * a1 + a2 * m + a3), y + k * cos(n * a1 + a2 * m + a3 + a4) + dy, z +
                        R * sin(n * a1 + a2 * m + a3),
                        x + R * cos(n * a1 + a2 * (m + 1) + a3), y + k * cos(n * a1 + a2 * (m + 1) + a3 + a4) + dy,
                        z + R * sin(n * a1 + a2 * (m + 1) + a3),
                        x + r * cos(n * a1 + a2 * (m + 1) + a3), y + k * cos(n * a1 + a2 * (m + 1) + a3 + a4) + dy,
                        z + r * sin(n * a1 + a2 * (m + 1) + a3)
                    )
                end
            end
        end
        ---left
        for i = 1, self.m do SetImageState(self.imgs[i], 'mul+alpha', Color(180, 200, 60, 60)) end
        local R = 2.75
        local r = 3
        local a1 = 360 / self.n
        local a2 = a1 / self.m
        local a3 = self.timer * 0.3
        local a4 = self.timer * 0.2 + 90
        local k = 0.5
        local x = -0.5
        local y = 2.75
        local z = 1
        for distrep = -rep_max, rep_max do
            local dy = dist + distrep * 6
            for n = 1, self.n do
                for m = 1, self.m do
                    Render4V(self.imgs[m],
                        x + r * cos(n * a1 + a2 * m + a3), y + k * cos(n * a1 + a2 * m + a3 + a4) + dy, z +
                        r * sin(n * a1 + a2 * m + a3),
                        x + R * cos(n * a1 + a2 * m + a3), y + k * cos(n * a1 + a2 * m + a3 + a4) + dy, z +
                        R * sin(n * a1 + a2 * m + a3),
                        x + R * cos(n * a1 + a2 * (m + 1) + a3), y + k * cos(n * a1 + a2 * (m + 1) + a3 + a4) + dy,
                        z + R * sin(n * a1 + a2 * (m + 1) + a3),
                        x + r * cos(n * a1 + a2 * (m + 1) + a3), y + k * cos(n * a1 + a2 * (m + 1) + a3 + a4) + dy,
                        z + r * sin(n * a1 + a2 * (m + 1) + a3)
                    )
                end
            end
        end
        local R = 2.25
        local r = 2.5
        for distrep = -rep_max, rep_max do
            local dy = dist + distrep * 6
            for n = 1, self.n do
                for m = 1, self.m do
                    Render4V(self.imgs[m],
                        x + r * cos(n * a1 + a2 * m + a3), y + k * cos(n * a1 + a2 * m + a3 + a4) + dy, z +
                        r * sin(n * a1 + a2 * m + a3),
                        x + R * cos(n * a1 + a2 * m + a3), y + k * cos(n * a1 + a2 * m + a3 + a4) + dy, z +
                        R * sin(n * a1 + a2 * m + a3),
                        x + R * cos(n * a1 + a2 * (m + 1) + a3), y + k * cos(n * a1 + a2 * (m + 1) + a3 + a4) + dy,
                        z + R * sin(n * a1 + a2 * (m + 1) + a3),
                        x + r * cos(n * a1 + a2 * (m + 1) + a3), y + k * cos(n * a1 + a2 * (m + 1) + a3 + a4) + dy,
                        z + r * sin(n * a1 + a2 * (m + 1) + a3)
                    )
                end
            end
        end
        ---right
        for i = 1, self.m do SetImageState(self.imgs[i], 'mul+alpha', Color(180, 60, 60, 200)) end
        local R = 2.75
        local r = 3
        local a1 = 360 / self.n
        local a2 = a1 / self.m
        local a3 = self.timer * 0.3
        local a4 = self.timer * 0.2 - 90
        local k = 0.5
        local x = 1
        local y = 2.75
        local z = 1
        for distrep = -rep_max, rep_max do
            local dy = dist + distrep * 6
            for n = 1, self.n do
                for m = 1, self.m do
                    Render4V(self.imgs[m],
                        x + r * cos(n * a1 + a2 * m + a3), y + k * cos(n * a1 + a2 * m + a3 + a4) + dy, z +
                        r * sin(n * a1 + a2 * m + a3),
                        x + R * cos(n * a1 + a2 * m + a3), y + k * cos(n * a1 + a2 * m + a3 + a4) + dy, z +
                        R * sin(n * a1 + a2 * m + a3),
                        x + R * cos(n * a1 + a2 * (m + 1) + a3), y + k * cos(n * a1 + a2 * (m + 1) + a3 + a4) + dy,
                        z + R * sin(n * a1 + a2 * (m + 1) + a3),
                        x + r * cos(n * a1 + a2 * (m + 1) + a3), y + k * cos(n * a1 + a2 * (m + 1) + a3 + a4) + dy,
                        z + r * sin(n * a1 + a2 * (m + 1) + a3)
                    )
                end
            end
        end
        local R = 2.25
        local r = 2.5
        for distrep = -rep_max, rep_max do
            local dy = dist + distrep * 6
            for n = 1, self.n do
                for m = 1, self.m do
                    Render4V(self.imgs[m],
                        x + r * cos(n * a1 + a2 * m + a3), y + k * cos(n * a1 + a2 * m + a3 + a4) + dy, z +
                        r * sin(n * a1 + a2 * m + a3),
                        x + R * cos(n * a1 + a2 * m + a3), y + k * cos(n * a1 + a2 * m + a3 + a4) + dy, z +
                        R * sin(n * a1 + a2 * m + a3),
                        x + R * cos(n * a1 + a2 * (m + 1) + a3), y + k * cos(n * a1 + a2 * (m + 1) + a3 + a4) + dy,
                        z + R * sin(n * a1 + a2 * (m + 1) + a3),
                        x + r * cos(n * a1 + a2 * (m + 1) + a3), y + k * cos(n * a1 + a2 * (m + 1) + a3 + a4) + dy,
                        z + r * sin(n * a1 + a2 * (m + 1) + a3)
                    )
                end
            end
        end
    end

end

function HM_hzc4_background:frame()
    if self.angle < -180 then
        self.angle = 0
    else
        self.angle = self.angle - 0.1
    end
    if not self.speed then self.speed = 0.08 end
    if not self.loop_dist then self.loop_dist = 6 end
    -- 隧道穿梭：累积前进距离，达到循环周期时重置
    -- 注意 flag 之后这里也照常累加，免得第一帧的滚动速度突然断掉
    self.distance = (self.distance or 0) + self.speed
    if self.distance >= self.loop_dist then
        self.distance = self.distance - self.loop_dist
    end
    if self.flag then
        -- 出隧道和抬升走同一条时间轴：总进度 P 从 0 平滑走到 1，两段以 P=half 分界。
        -- 因为缓动只做了一条，P=half 处速度正好最大，所以两段之间不会有停顿。
        -- 全部走完之后彻底不再调用 Set3D，camera_setter 之类的调整才不会被覆盖。
        local total = self.exit_duration + self.rise_duration
        if self.move_timer < total then
            self.move_timer = self.move_timer + 1
            local T = self.move_timer / total
            local P = T * T * (3 - 2 * T)
            -- 分界点取"第 exit_duration 帧"对应的 P：这样第一段正好是 exit_duration 帧，
            -- 同时因为两段都线性于 P、而 P 是全程连续缓动的，接缝处速度也自然接得上。
            local Tb = self.exit_duration / total
            local Pb = Tb * Tb * (3 - 2 * Tb)
            if P < Pb then
                -- 第一段：钻出隧道
                local s = P / Pb
                self.exit_s = s
                -- 先沿隧道轴向（-y）飞出隧道口，出了隧道口之后再升到地面上方
                local pz = max(0, min(1, (s - 0.60) / 0.40))
                local ex = self.exit_eye0[1] + (self.exit_eye1[1] - self.exit_eye0[1]) * s
                local ey = self.exit_eye0[2] + (self.exit_eye1[2] - self.exit_eye0[2]) * s
                local ez = self.exit_eye0[3] + (self.exit_eye1[3] - self.exit_eye0[3]) * pz * pz
                -- 视线在 yz 平面内连续低头，up 始终与视线垂直，避免出现万向锁。
                -- 注意：LuaSTG 的全局 sin/cos 是角度制（见 lstg.DegreesMath），
                --       所以 ang 必须保持为「度」，绝对不能再乘 PI/180，
                --       否则角度会被压缩 57.3 倍，摄像机永远低不下头。
                local ang = self.exit_ang0 + (self.exit_ang1 - self.exit_ang0) * s
                local vy, vz = sin(ang), cos(ang)
                Set3D('eye', ex, ey, ez)
                Set3D('at', ex, ey + vy * self.exit_at_dist, ez + vz * self.exit_at_dist)
                Set3D('up', 0, cos(ang), -sin(ang))
                -- 视野随高度打开，雾推远变淡。清屏色（也就是雾色）从隧道深处的
                -- 蓝紫渐变到天空色 —— 隧道不再重复渲染之后，视野正中会露出清屏色，
                -- 用灰色就会突兀地"变灰"，用隧道本身的蓝紫才接得上。
                Set3D('z', 0.1, 24 + 26 * s)
                Set3D('fog', 7 + 11 * s, 20 + 25 * s, Color(255,
                    math.floor(112 + 88 * s),
                    math.floor(114 + 91 * s),
                    math.floor(176 + 54 * s)))
            else
                -- 第二段：继续抬升机位，离地面更高
                local rs = (P - Pb) / (1 - Pb)
                self.exit_s = 1 -- 第一段已经走完，地面/雾气的淡入不再变化
                self.rise_s = rs
                local ey = self.exit_eye1[2]
                local ez = self.exit_eye1[3] + (self.rise_eye_z - self.exit_eye1[3]) * rs
                -- 只抬高机位，视线保持垂直向下
                Set3D('eye', 0, ey, ez)
                Set3D('at', 0, ey, ez - self.exit_at_dist)
                Set3D('up', 0, -1, 0)
                -- 视野随高度继续打开。这里必须把雾的可见距离一起推远，否则地面
                -- 会被 D3D 雾整个吃掉；"雾越来越浓"交给云层和雾片去表现。
                Set3D('z', 0.1, 50 + 60 * rs)
                Set3D('fog', 18 + 12 * rs, 45 + 50 * rs, Color(255, 200, 205, 230))
            end
        end
    end
    -- 地面和雾气不断向前滚动
    self.scroll = self.scroll + self.scroll_speed
end

function HM_hzc4_background:render()
    SetViewMode '3d'
    RenderClear(lstg.view3d.fog[3])
    local showboss = IsValid(_boss)
    if showboss then
        PostEffectCapture()
        RenderClear(lstg.view3d.fog[3])
    end
    ---
    -- 地面和雾气直接内联在这里，不经过任何自定义方法，避免方法取不到导致 render 中断。
    -- 画家算法（本引擎没有深度缓冲，后画的必定覆盖先画的）：
    -- 先画最远的地面(z=ground_z)，再画贴地的云层(由低到高)，最后画最近的隧道。
    if self.flag then
        local e = self.exit_s or 0

        -- 地面：z = ground_z 的 xy 平面，用 bg5 铺瓦片并沿 y 方向循环滚动
        -- 摄像机钻出隧道口的时候地面才逐渐显现出来
        local ga = max(0, min(1, (e - 0.30) / 0.50))
        if ga > 0 then
            SetImageState('bg5', 'mul+alpha', Color(math.floor(255 * ga), 255, 255, 255))
            local s = self.ground_tile
            local off = self.scroll % s
            local z = self.ground_z
            -- 以摄像机终点为中心，前后各多铺两块，保证滚动时不会露边
            local y0 = self.exit_eye1[2] - s * 2
            -- 抬升之后视野会变大，多铺一圈防止露边
            for i = -2, 1 do
                for j = 0, 3 do
                    local x0 = i * s
                    local ya = y0 + j * s + off
                    Render4V('bg5',
                        x0, ya, z,
                        x0 + s, ya, z,
                        x0 + s, ya + s, z,
                        x0, ya + s, z)
                end
            end
        end

        -- 雾气：用 bg4 云层贴着地面铺开，同样沿 y 循环滚动，层与层速度不同形成视差
        local fa = max(0, min(1, (e - 0.35) / 0.50))
        if fa > 0 then
            local rs = self.rise_s or 0
            for _, L in ipairs(self.fog_layers) do
                -- 抬升过程中云层逐渐变浓
                local a = (L.alpha + (L.rise_alpha - L.alpha) * rs) * fa
                SetImageState('bg4', 'mul+alpha', Color(math.floor(a), 235, 245, 255))
                local s = L.tile
                local off = (self.scroll * L.speed) % s
                local y0 = self.exit_eye1[2] - s * 2
                for i = -1, 0 do
                    for j = 0, 2 do
                        local x0 = i * s
                        local ya = y0 + j * s + off
                        Render4V('bg4',
                            x0, ya, L.z,
                            x0 + s, ya, L.z,
                            x0 + s, ya + s, L.z,
                            x0, ya + s, L.z)
                    end
                end
            end
        end

        -- 小片雾（bg6）：抬升过程中围绕摄像机的一层层薄雾。
        -- 层固定在世界坐标的 z 网格上，机位抬高时它们相对摄像机向下掠过；
        -- 水平方向跟着 scroll 流动，各层速度不同形成视差，摄像机停住后雾也还在动。
        local ma = self.mist.alpha * (self.rise_s or 0) * fa
        if ma > 0 then
            local mt = self.mist.tile
            local mg = self.mist.gap
            local mz = self.mist.layer_z
            -- 这里直接读相机当前位置，而不是重新推算：
            -- 抬升到位后即使手动用 camera_setter 抬高机位，雾片也会跟着正确响应
            local ey = lstg.view3d.eye[2]
            local ez = lstg.view3d.eye[3]
            local z_base = self.ground_z + 4
            -- 由远到近画（z 低的层离摄像机远），保证近处的雾片盖在远处之上
            for L = 0, self.mist.layers - 1 do
                -- 每层再叠一点缓慢的上下浮动，免得雾看起来是钉死在半空的
                local bob = 2 * sin(self.timer * 0.7 + L * 40)
                local z = z_base + L * mz + bob
                -- 太靠近地面或者太靠近摄像机（跑到机位上方）的层都渐隐掉
                local fade = min(1, (z - self.ground_z) / 12) * min(1, (ez - z) / 12)
                if fade > 0 then
                    SetImageState('bg6', 'mul+alpha', Color(math.floor(ma * fade), 245, 248, 255))
                    local off = (self.scroll * (1.0 + 0.25 * L)) % mg
                    for i = -1, 1 do
                        for j = -1, 1 do
                            local x0 = i * mg - mt * 0.5
                            local y0 = ey + j * mg + off - mt * 0.5
                            Render4V('bg6',
                                x0, y0, z,
                                x0 + mt, y0, z,
                                x0 + mt, y0 + mt, z,
                                x0, y0 + mt, z)
                        end
                    end
                end
            end
        end
    end
    -- 第一段走完之后就彻底不画隧道了（用 exit_s 判断，它到 1 就表示已经钻出来）
    if not (self.flag and (self.exit_s or 0) >= 1) then
        self:render_tunnel()
    end
    if showboss then
        local x, y = WorldToScreen(_boss.x, _boss.y)
        local x1 = x * screen.scale
        local y1 = (screen.height - y) * screen.scale
        local fxr = _boss.fxr or 163
        local fxg = _boss.fxg or 73
        local fxb = _boss.fxb or 164
        PostEffectApply("boss_distortion", "", {
            centerX = x1,
            centerY = y1,
            size = _boss.aura_alpha * 200 * lstg.scale_3d,
            color = Color(125, fxr, fxg, fxb),
            colorsize = _boss.aura_alpha * 200 * lstg.scale_3d,
            arg = 1500 * _boss.aura_alpha / 128 * lstg.scale_3d,
            timer = self.timer
        })
    end
    SetViewMode 'world'
    --
end
