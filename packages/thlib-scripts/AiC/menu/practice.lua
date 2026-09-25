local lib = aic.menu

------------------------------------------------------------

---练习模式
lib.practice = Class(object)

function lib.practice:init()
    self.class = lib.practice
    self.num = 4
    self.group = GROUP_GHOST
    self.layer = LAYER_TOP
    self.bound = false
    self.alpha = 0
    self.x, self.y = lib.GetScreenCenter()
    self.x = self.x - screen.width
    self.y = self.y - screen.height
    self.default_x, self.default_y = self.x, self.y
    lib.RegistMenu(self)
end