---THLoOP Added
--======================================
--THlib music
--======================================

--神妈的小曲
DeathMusic = 'bgm0'

--一定记得查采样率！不是每首都是44100的！
lstg.bgm_loop = {
    [0] = { 34.834, 27.54 },--疮痍曲
    { 104.285, 91.428 },
    { 134.651, 78.140 },
    { 279.768, 178.605 },
    { 63, 63 }
}   
--]]

local loop = lstg.bgm_loop
for i = 0, 4 do
    MusicRecord("bgm" .. i, "THlib/music/bgm" .. i .. ".ogg", loop[i][1], loop[i][2])
end
