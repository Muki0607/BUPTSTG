---THLoOP Added
--======================================
--THlib music
--======================================

--家乡的小曲
MusicRecord("spellcard", 'THlib/music/spellcard.ogg', 75, 0xc36e80 / 44100 / 4)

--神妈的小曲
DeathMusic = 'bgm1'

--一定记得查采样率！不是每首都是44100的！
lstg.bgm_loop = {
    [0] = { 87.8, 79.26 },--LuaSTG原版标题曲
    {           34.834,            27.54 },--疮痍曲
}   
--]]

lstg.bgm_volume = {}

local loop = lstg.bgm_loop
for i = 0, 1 do
    MusicRecord("bgm" .. i, "THlib/music/bgm" .. i .. ".ogg", loop[i][1], loop[i][2])
end
