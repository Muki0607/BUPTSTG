local lib = aic.menu

------------------------------------------------------------

---符卡练习
lib.spell_practice = Class(object)

function lib.spell_practice:init()
    self.class = lib.spell_practice
    self.num = 5
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.bound = false
    self.alpha = 0
    self.x, self.y = lib.GetScreenCenter()
    self.x = self.x + screen.width
    self.y = self.y - screen.height
    self.default_x, self.default_y = self.x, self.y
    lib.RegistMenu(self)
end