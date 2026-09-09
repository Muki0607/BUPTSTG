---THLoOP Added
--======================================
--THlib music
--======================================

--家乡的小曲
MusicRecord("spellcard", 'THlib/music/spellcard.ogg', 75, 0xc36e80 / 44100 / 4)

--神妈的小曲
DeathMusic = 'bgm1'

--正式版曲目
--一定记得查采样率！不是每首都是44100的！
lstg.bgm_loop = {
}   
--]]

lstg.bgm_volume = {}

local loop = lstg.bgm_loop
--[[
for i = 0, 30 do
    MusicRecord("bgm" .. i, "THlib/music/bgm" .. i .. ".ogg", loop[i][1], loop[i][2])
end
--]]

