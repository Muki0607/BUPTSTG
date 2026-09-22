// ======================================
// 水面涟漪效果 + 结界纹理 + 流线展开 - HLSL 版本
// 由 water_ripple_shader.glsl 转换而来，用于 LuaSTG
// ======================================

// 引擎设置的参数，不可修改

SamplerState screen_texture_sampler : register(s4); // RenderTarget 纹理的采样器
Texture2D    screen_texture         : register(t4); // RenderTarget 纹理（捕获的游戏画面，相当于 iChannel0）
cbuffer engine_data : register(b1)
{
    float4 screen_texture_size; // 纹理大小
    float4 viewport;            // 视口
};

// 用户传递的浮点参数

cbuffer user_data : register(b0)
{
    // waterCenterX, waterCenterY（水面中心，归一化 0-1，y 向下）
    // rippleCenterX, rippleCenterY（涟漪中心，归一化 0-1，y 向下）
    float4 center_param;
    // expandRadius（展开半径 0-1）, alpha（整体透明度）, timer（动画计时，秒）, disturb（展开扰动幅度）
    float4 effect_param;
    // 水面着色 rgb, barrier_strength（结界强度）
    float4 tint_param;
};

// 结界纹理（相当于 iChannel1）
SamplerState barrier_sampler : register(s0);
Texture2D    barrier_texture : register(t0);

// 宏定义，方便对应 GLSL
#define waterCenter   center_param.xy
#define rippleCenter  center_param.zw
#define expandRadius  effect_param.x
#define fx_alpha      effect_param.y
#define fx_time       effect_param.z
#define disturbAmt    effect_param.w
#define waterTint     tint_param.xyz
#define barrierAmt    tint_param.w

// 不变量

static const float inner = 1.0f; // 防撕裂的边距（像素）

// 主函数

struct PS_Input
{
    float4 sxy : SV_Position;
    float2 uv  : TEXCOORD0;
    float4 col : COLOR0;
};
struct PS_Output
{
    float4 col : SV_Target;
};

PS_Output main(PS_Input input)
{
    float2 uv = input.uv;

    // 宽高比修正（对应 GLSL 的 iResolution.x / iResolution.y）
    float aspect = screen_texture_size.x / screen_texture_size.y;

    float time  = fx_time;

    // ============ 涟漪扭曲计算 ============
    float2 toWaterCenter = uv - waterCenter;
    float distToWater = length(toWaterCenter * float2(aspect, 1.0f));

    // ======== 流线展开扰动 ========
    float angle = atan2(toWaterCenter.y, toWaterCenter.x); // 像素相对水面中心的角度
    float edgeDisturbance = 0.0f;

    // 只在展开阶段添加扰动
    if (expandRadius < 1.0f)
    {
        float wave1 = sin(angle * 5.0f  + time * 3.0f) * 0.5f + 0.5f;
        float wave2 = sin(angle * 8.0f  - time * 4.0f) * 0.3f + 0.5f;
        float wave3 = sin(angle * 12.0f + time * 5.0f) * 0.2f + 0.5f;

        // 扰动强度随展开进度衰减（最终完全消失）
        float disturbStrength = (1.0f - expandRadius) * disturbAmt;
        edgeDisturbance = (wave1 * 0.5f + wave2 * 0.3f + wave3 * 0.2f - 0.5f) * disturbStrength;
    }

    // 有效半径 = 展开半径 + 扰动
    float effectiveRadius = expandRadius + edgeDisturbance;

    // 计算到涟漪中心的距离（用于涟漪效果）
    float2 toRippleCenter = uv - rippleCenter;
    float distToRipple = length(toRippleCenter * float2(aspect, 1.0f));

    float2 offset  = float2(0.0f, 0.0f);
    float  falloff = 0.0f;
    float  gloss   = 0.0f; // 波光高光强度（透明水的灵魂）

    // 只在水面范围内产生涟漪效果
    if (distToWater < effectiveRadius)
    {
        falloff = 1.0f - smoothstep(0.0f, expandRadius, distToRipple);

        // 方向：从涟漪中心指向当前像素（normalize 前保护零向量）
        float rlen = max(distToRipple, 1e-5f);
        float2 dir = toRippleCenter / rlen;

        // —— 参考知乎水波纹：对波形做有限差分求“斜率”，得到水面梯度（法线水平分量）——
        // 这样波峰波谷折射方向相反，才是真实水的扭曲；比恒正推 UV 更像水
        float hstep = 1.5e-3f;
        float dA = distToRipple - hstep;
        float dB = distToRipple + hstep;
        // 多频同心波，随时间向外传播
        // 每个 sin(d * 频率 - time * 速度)：频率越大波越密，速度越大波扩散越快
        float wA = sin(dA * 50.0f - time * 13.0f) + 0.5f * sin(dA * 95.0f - time * 19.0f);
        float wB = sin(dB * 50.0f - time * 13.0f) + 0.5f * sin(dB * 95.0f - time * 19.0f);
        float slope = (wB - wA) / (2.0f * hstep); // dHeight/dDist

        // 把梯度当作“伪法线”的水平分量（GRAD_SCALE 控制波纹起伏幅度）
        const float GRAD_SCALE = 0.012f;   // 波纹幅度，越大越明显（0.008~0.02）
        float2 g = dir * slope * falloff * GRAD_SCALE;

        // 伪法线：z 用 sin(dot(g,g)) 保持很小，让高光只出现在波纹斜坡上
        // （平静水面 g≈0 => 无折射、无高光）
        float3 n = float3(g, sin(dot(g, g)));

        // 折射偏移：透明水“隔着水看画面”的扭曲
        // 乘 fx_alpha，让扭曲跟随淡出阶段一起收（否则结束时扭曲会瞬间归零、显得很突兀）
        const float REFRACT = 0.03f;       // 折射强度，越大越扭（0.02~0.05）
        offset = n.xy * REFRACT * fx_alpha;

        // 波光高光：法线朝向光源时反光，pow 收紧成条状闪光
        gloss = 5.0f * pow(saturate(dot(n, normalize(float3(1.0f, 0.7f, 0.5f)))), 6.0f);
    }

    // ============ 采样扭曲后的纹理 ============
    // 防边缘撕裂：先把扭曲量换算成像素位置，越界则放弃扭曲、用原始 uv
    // （参考 boss_distortion.hlsl 的做法）
    float2 distortedUV = uv;
    float2 xy = uv * screen_texture_size.xy;                 // 当前像素真实位置
    float2 resultxy = xy + offset * screen_texture_size.xy;  // 扭曲后的像素位置
    if (resultxy.x > (viewport.x + inner) && resultxy.x < (viewport.z - inner) &&
        resultxy.y > (viewport.y + inner) && resultxy.y < (viewport.w - inner))
    {
        distortedUV = uv + offset; // 目标在视口内，正常扭曲
    }
    float4 sceneColor = screen_texture.Sample(screen_texture_sampler, distortedUV);

    // ============ 结界纹理叠加 ============
    if (distToWater < effectiveRadius)
    {
        // 结界纹理 UV：固定在【游戏区】中央（不是窗口中央）
        // 游戏区在窗口里通常偏左（右侧有UI留白），故用 viewport 算真实中心
        // viewport = (left, top, right, bottom) 像素坐标
        float2 xy = uv * screen_texture_size.xy;              // 当前像素真实位置
        float2 vp_center = float2((viewport.x + viewport.z) * 0.5f,
                                  (viewport.y + viewport.w) * 0.5f);
        float  vp_height = viewport.w - viewport.y;           // 游戏区高度（像素）
        // barrier_scale：结界图相对游戏区高度的占比（1.0=铺满游戏区高度，越小图越大）
        float  barrier_scale = 1.0f;
        // 以游戏区高度为基准做等比映射，x、y 用同一尺度 => 不拉伸
        float2 barrierUV = (xy - vp_center) / (vp_height * barrier_scale) + 0.5f;

        // 采样结界纹理（受涟漪扭曲影响）
        float4 barrierColor = barrier_texture.Sample(barrier_sampler, barrierUV + offset * 0.5f);

        // 结界可见度（基于到水面中心的距离）
        float barrierFalloff = 1.0f - smoothstep(0.0f, expandRadius, distToWater);
        float ba = barrierColor.a * barrierFalloff * fx_alpha * barrierAmt;

        // alpha 混合：结界直接覆盖场景（比加法更清晰，暗色结界也看得见）
        sceneColor.rgb = lerp(sceneColor.rgb, barrierColor.rgb, ba);
        // 若想要发光叠加效果，改回加法：sceneColor.rgb += barrierColor.rgb * ba;
    }

    // ============ 水面着色 + 波光 ============
    // 透明水思路：几乎不染色，颜色 = 折射后的场景 + 方向性波光高光
    float tintStrength = 0.08f * fx_alpha; // 极淡着色，只给一点水色倾向（0 = 完全无色）

    if (distToWater < effectiveRadius)
    {
        sceneColor.rgb = lerp(sceneColor.rgb, sceneColor.rgb * waterTint, tintStrength);

        // 波光高光（来自法线求导的 gloss）—— 透明水的关键，只在波纹斜坡闪白光
        sceneColor.rgb += float3(1.0f, 1.0f, 1.0f) * gloss * fx_alpha;
    }

    // ============ 水面边缘光晕 ============
    float edge = smoothstep(effectiveRadius - 0.05f, effectiveRadius, distToWater);
    float3 edgeGlow = float3(0.7f, 0.85f, 1.0f) * (1.0f - edge) * 0.35f * fx_alpha;
    // sceneColor.rgb += edgeGlow;

    // ============ 最终输出 ============
    sceneColor.a = 1.0f;

    PS_Output output;
    output.col = sceneColor;
    return output;
}
