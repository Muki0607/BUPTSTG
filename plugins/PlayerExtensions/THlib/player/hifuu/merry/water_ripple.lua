--------------------------------------------------------------------------------
--- 水面涟漪 Bomb 特效
--- 捕获游戏画面 -> 传入 water_ripple.hlsl -> 输出扭曲后的水面效果
---
--- 用法：
---   local water = require("lib.water_ripple")
---   water.load("assets/barrier.png")   -- 加载结界纹理（一次即可）
---
---   -- 在需要捕获的渲染之前：
---   water.beginCapture()
---   ... 绘制敌人、子弹等图层 ...
---   -- 捕获结束、应用特效并绘制出来：
---   water.apply(centerWorldX, centerWorldY, rippleWorldX, rippleWorldY,
---               expandRadius, alpha, timer)
--------------------------------------------------------------------------------

---@class water_ripple
local water_ripple = {}

local FX_NAME       = "$fx:water_ripple"
-- shader 实际放在梅莉角色目录下（THlib/player/hifuu/merry/water_ripple.hlsl）
local FX_PATH       = "THlib/player/hifuu/merry/water_ripple.hlsl"
local RT_NAME       = "$rt:water_ripple"
local BARRIER_TEX   = "$tex:water_ripple_barrier"

local loaded = false
local has_barrier = false -- 是否成功加载了结界纹理
local capturing = false   -- 当前是否处于捕获状态（保证 Push/Pop 严格配对，防止渲染栈失衡）

--- 加载 shader、渲染目标、结界纹理（重复调用安全）
--- 结界纹理可选，缺失时 bomb 仍能正常显示水面涟漪
---@param barrier_image_path string|nil 结界纹理图片路径
function water_ripple.load(barrier_image_path)
    if not lstg.CheckRes(9, FX_NAME) then
        lstg.LoadFX(FX_NAME, FX_PATH)
    end
    if not lstg.CheckRes(1, RT_NAME) then
        lstg.CreateRenderTarget(RT_NAME)
    end
    if barrier_image_path then
        if not lstg.CheckRes(1, BARRIER_TEX) then
            lstg.LoadTexture(BARRIER_TEX, barrier_image_path)
        end
        has_barrier = lstg.CheckRes(1, BARRIER_TEX) or false
    end
    loaded = true
end

--- 运行时补加结界纹理（若之前没提供路径）
---@param barrier_image_path string
function water_ripple.setBarrier(barrier_image_path)
    if barrier_image_path and not lstg.CheckRes(1, BARRIER_TEX) then
        lstg.LoadTexture(BARRIER_TEX, barrier_image_path)
    end
    has_barrier = lstg.CheckRes(1, BARRIER_TEX) or false
end

--- 开始捕获画面
function water_ripple.beginCapture()
    if not loaded then return end
    if capturing then return end -- 已在捕获中，避免重复 Push
    lstg.PushRenderTarget(RT_NAME)
    lstg.RenderClear(lstg.Color(0, 0, 0, 0))
    capturing = true
end

--- 是否处于捕获状态（供 apply 侧判断）
function water_ripple.isCapturing()
    return capturing
end

--- 结束捕获并应用水面特效、绘制出来
---@param cx number 水面中心世界坐标 x
---@param cy number 水面中心世界坐标 y
---@param rx number 涟漪中心世界坐标 x（一般为玩家当前位置）
---@param ry number 涟漪中心世界坐标 y
---@param expandRadius number 展开半径 0-1
---@param alpha number 整体透明度 0-1
---@param timer number 动画计时（秒），一般为 self.timer / 60
---@param disturb number|nil 展开扰动幅度，默认 0.25
---@param tint table|nil 水面着色 {r,g,b}（0-1），默认 {0.6,0.8,1.0}
---@param barrierStrength number|nil 结界强度，默认 0.7
function water_ripple.apply(cx, cy, rx, ry, expandRadius, alpha, timer, disturb, tint, barrierStrength)
    if not loaded then return end
    if not capturing then return end -- 未处于捕获状态，说明 beginCapture 没执行，跳过防止栈失衡

    lstg.PopRenderTarget(RT_NAME)
    capturing = false

    -- 世界坐标 -> 屏幕像素坐标（参考 background.WarpEffectApply）
    local wcx, wcy = WorldToScreen(cx, cy)
    local wrx, wry = WorldToScreen(rx, ry)

    -- 归一化到 0-1，并翻转 Y（屏幕坐标 y 向上，纹理 uv y 向下）
    local W = screen.width
    local H = screen.height
    local ncx = wcx / W
    local ncy = 1.0 - wcy / H
    local nrx = wrx / W
    local nry = 1.0 - wry / H

    disturb = disturb or 0.25
    -- 水面着色（0-1）。透明水建议偏淡、别用纯蓝：
    --   偏青透明水 {0.75, 0.9, 1.0}；更中性 {0.85, 0.92, 1.0}；想更蓝改回 {0.6, 0.8, 1.0}
    tint = tint or { 0.8, 0.9, 1.0 }
    barrierStrength = barrierStrength or 1.0 -- 结界透明度总开关，越大越清晰（0-1，还想更亮可 >1）

    -- 无结界纹理时：强度归零 + 不传纹理参数（避免引用不存在的资源）
    local tex_params = {}
    if has_barrier then
        tex_params = { { BARRIER_TEX, 6 } }
    else
        barrierStrength = 0.0
    end

    lstg.PostEffect(
        FX_NAME,
        RT_NAME, 6,
        "mul+alpha",
        {
            { ncx, ncy, nrx, nry },                        -- center_param
            { expandRadius, alpha, timer, disturb },       -- effect_param
            { tint[1], tint[2], tint[3], barrierStrength },-- tint_param
        },
        tex_params
    )
end

-- 通过 Include 加载（引擎在 afterTHlib 阶段的 require 搜索路径不含 thlib-scripts 根），
-- 故挂到全局变量供 hifuu.lua 使用；同时保留 return 以兼容 require 方式
hifuu_water_ripple = water_ripple
return water_ripple
