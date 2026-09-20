HM_hzc4_background=Class(object)
hm_bg_hzc4=false
--
----辉针城四面背景
----使用或修改时请注明原作者。
----素材来源于原作拆包
----感谢莉莉姐和青山老爷的指点
function HM_hzc4_background:init()
	background.init(self,false)
	
	self.m=8
	self.imgs={}
	self.angle=0
	--rescore
	LoadImageFromFile('stg4bg1','THlib/background/hm_hzc4/stg4bg1.png')
	LoadImageFromFile('stg4bg2','THlib/background/hm_hzc4/stg4bg2.png')
	LoadImageFromFile('stg4bg3','THlib/background/hm_hzc4/stg4bg3.png')
	LoadImageGroup('hm_hzc3_','stg4bg3',0,0,128,512/self.m,1,self.m,0,0)
	for i=1,self.m do self.imgs[i]='hm_hzc3_'..i end
	--
	self.z=4
	Set3D('eye',0,6,0)
	Set3D('at',0,2,2.5)
	Set3D('up',0,1,0)
	Set3D('z',0.1,24)
	Set3D('fovy',0.7)
	Set3D('fog',7,20,Color(0x80500030))
	--
	self.n=12  
	--
	SetImageState('stg4bg1', 'mul+alpha',Color(200,255,255,255))
	SetImageState('stg4bg2', 'mul+alpha',Color(100,255,255,255))
	SetImageState('stg4bg3', 'mul+alpha',Color(200,255,255,255))
end

function HM_hzc4_background:frame()
	if self.angle<-180 then
		self.angle=0
	else
		self.angle=self.angle-0.1
	end
	-- 隧道穿梭：累积前进距离，达到循环周期时重置
	if not self.speed then self.speed = 0.08 end
	if not self.loop_dist then self.loop_dist = 6 end
	self.distance = (self.distance or 0) + self.speed
	if self.distance >= self.loop_dist then
		self.distance = self.distance - self.loop_dist
	end
end

function HM_hzc4_background:render()
	SetViewMode'3d'
	RenderClear(lstg.view3d.fog[3])
	local showboss = IsValid(_boss)
	if showboss then
        PostEffectCapture()
		RenderClear(lstg.view3d.fog[3])
    end
	---

	local R=6
	local d = self.distance or 0
	-- 扩展绘制范围以支持循环，多绘制几圈覆盖视野
	for rep=-2,2 do
		for i=1,12 do
			for j=1,12 do
				Render4V('stg4bg1',
						R*cos(30*i),-24+R*(j+1)+d+rep*R*12,R*sin(30*i),
						R*cos(30*i),-24+R*j+d+rep*R*12,R*sin(30*i),
						R*cos(30*(i+1)),-24+R*j+d+rep*R*12,R*sin(30*(i+1)),
						R*cos(30*(i+1)),-24+R*(j+1)+d+rep*R*12,R*sin(30*(i+1))
						)
			end
		end
	end
	--
	local R=5  
	for rep=-2,2 do
		for i=1,12 do
			for j=1,12 do
				Render4V('stg4bg2',
						R*cos(self.angle+30*i),-20+R*(j+1)+d+rep*R*12,R*sin(self.angle+30*i),
						R*cos(self.angle+30*i),-20+R*j+d+rep*R*12,R*sin(self.angle+30*i),
						R*cos(self.angle+30*(i+1)),-20+R*j+d+rep*R*12,R*sin(self.angle+30*(i+1)),
						R*cos(self.angle+30*(i+1)),-20+R*(j+1)+d+rep*R*12,R*sin(self.angle+30*(i+1))
						
						)
			end
		end
	end
	---bot
	for i=1,self.m do SetImageState(self.imgs[i],'mul+alpha',Color(180,255,255,255)) end
	
	local R=2.25	local r=2
	local a1=360/self.n		local a2=a1/self.m		local a3=self.timer*0.3  local a4=self.timer*0.1
	local k=0.5
	local x=0.5	local y=0.75	local z=1
	local dist = self.distance or 0
	for distrep=-2,2 do
		local dy = dist + distrep * 6
		for n=1,self.n do
			for m=1,self.m do
				Render4V(self.imgs[m],
						x+r*cos(n*a1+a2*m+a3),y+k*cos(n*a1+a2*m+a3+a4)+dy,z+r*sin(n*a1+a2*m+a3),
						x+R*cos(n*a1+a2*m+a3),y+k*cos(n*a1+a2*m+a3+a4)+dy,z+R*sin(n*a1+a2*m+a3),
						x+R*cos(n*a1+a2*(m+1)+a3),y+k*cos(n*a1+a2*(m+1)+a3+a4)+dy,z+R*sin(n*a1+a2*(m+1)+a3),
						x+r*cos(n*a1+a2*(m+1)+a3),y+k*cos(n*a1+a2*(m+1)+a3+a4)+dy,z+r*sin(n*a1+a2*(m+1)+a3)
						)
			end
		end
	end
	local R=2.75	local r=2.5
	for distrep=-2,2 do
		local dy = dist + distrep * 6
		for n=1,self.n do
			for m=1,self.m do
				Render4V(self.imgs[m],
						x+r*cos(n*a1+a2*m+a3),y+k*cos(n*a1+a2*m+a3+a4)+dy,z+r*sin(n*a1+a2*m+a3),
						x+R*cos(n*a1+a2*m+a3),y+k*cos(n*a1+a2*m+a3+a4)+dy,z+R*sin(n*a1+a2*m+a3),
						x+R*cos(n*a1+a2*(m+1)+a3),y+k*cos(n*a1+a2*(m+1)+a3+a4)+dy,z+R*sin(n*a1+a2*(m+1)+a3),
						x+r*cos(n*a1+a2*(m+1)+a3),y+k*cos(n*a1+a2*(m+1)+a3+a4)+dy,z+r*sin(n*a1+a2*(m+1)+a3)
						)
			end
		end
	end
	---left
	for i=1,self.m do SetImageState(self.imgs[i],'mul+alpha',Color(180,200,60,60)) end
	local R=2.75       local r=3
	local a1=360/self.n		local a2=a1/self.m		local a3=self.timer*0.3  local a4=self.timer*0.2+90
	local k=0.5
	local x=-0.5	local y=2.75	local z=1
	for distrep=-2,2 do
		local dy = dist + distrep * 6
		for n=1,self.n do
			for m=1,self.m do
				Render4V(self.imgs[m],
						x+r*cos(n*a1+a2*m+a3),y+k*cos(n*a1+a2*m+a3+a4)+dy,z+r*sin(n*a1+a2*m+a3),
						x+R*cos(n*a1+a2*m+a3),y+k*cos(n*a1+a2*m+a3+a4)+dy,z+R*sin(n*a1+a2*m+a3),
						x+R*cos(n*a1+a2*(m+1)+a3),y+k*cos(n*a1+a2*(m+1)+a3+a4)+dy,z+R*sin(n*a1+a2*(m+1)+a3),
						x+r*cos(n*a1+a2*(m+1)+a3),y+k*cos(n*a1+a2*(m+1)+a3+a4)+dy,z+r*sin(n*a1+a2*(m+1)+a3)
						)
			end
		end
	end
	local R=2.25	local r=2.5
	for distrep=-2,2 do
		local dy = dist + distrep * 6
		for n=1,self.n do
			for m=1,self.m do
				Render4V(self.imgs[m],
						x+r*cos(n*a1+a2*m+a3),y+k*cos(n*a1+a2*m+a3+a4)+dy,z+r*sin(n*a1+a2*m+a3),
						x+R*cos(n*a1+a2*m+a3),y+k*cos(n*a1+a2*m+a3+a4)+dy,z+R*sin(n*a1+a2*m+a3),
						x+R*cos(n*a1+a2*(m+1)+a3),y+k*cos(n*a1+a2*(m+1)+a3+a4)+dy,z+R*sin(n*a1+a2*(m+1)+a3),
						x+r*cos(n*a1+a2*(m+1)+a3),y+k*cos(n*a1+a2*(m+1)+a3+a4)+dy,z+r*sin(n*a1+a2*(m+1)+a3)
						)
			end
		end
	end
	---right
	for i=1,self.m do SetImageState(self.imgs[i],'mul+alpha',Color(180,60,60,200)) end
	local R=2.75	local r=3
	local a1=360/self.n		local a2=a1/self.m		local a3=self.timer*0.3  local a4=self.timer*0.2-90
	local k=0.5
	local x=1	local y=2.75	local z=1
	for distrep=-2,2 do
		local dy = dist + distrep * 6
		for n=1,self.n do
			for m=1,self.m do
				Render4V(self.imgs[m],
						x+r*cos(n*a1+a2*m+a3),y+k*cos(n*a1+a2*m+a3+a4)+dy,z+r*sin(n*a1+a2*m+a3),
						x+R*cos(n*a1+a2*m+a3),y+k*cos(n*a1+a2*m+a3+a4)+dy,z+R*sin(n*a1+a2*m+a3),
						x+R*cos(n*a1+a2*(m+1)+a3),y+k*cos(n*a1+a2*(m+1)+a3+a4)+dy,z+R*sin(n*a1+a2*(m+1)+a3),
						x+r*cos(n*a1+a2*(m+1)+a3),y+k*cos(n*a1+a2*(m+1)+a3+a4)+dy,z+r*sin(n*a1+a2*(m+1)+a3)
						)
			end
		end
	end
	local R=2.25	local r=2.5
	for distrep=-2,2 do
		local dy = dist + distrep * 6
		for n=1,self.n do
			for m=1,self.m do
				Render4V(self.imgs[m],
						x+r*cos(n*a1+a2*m+a3),y+k*cos(n*a1+a2*m+a3+a4)+dy,z+r*sin(n*a1+a2*m+a3),
						x+R*cos(n*a1+a2*m+a3),y+k*cos(n*a1+a2*m+a3+a4)+dy,z+R*sin(n*a1+a2*m+a3),
						x+R*cos(n*a1+a2*(m+1)+a3),y+k*cos(n*a1+a2*(m+1)+a3+a4)+dy,z+R*sin(n*a1+a2*(m+1)+a3),
						x+r*cos(n*a1+a2*(m+1)+a3),y+k*cos(n*a1+a2*(m+1)+a3+a4)+dy,z+r*sin(n*a1+a2*(m+1)+a3)
						)
			end
		end
	end
	
	if showboss then
		local x,y = WorldToScreen(_boss.x,_boss.y)
		local x1 = x * screen.scale
		local y1 = (screen.height - y) * screen.scale
		local fxr = _boss.fxr or 163
		local fxg = _boss.fxg or 73
		local fxb = _boss.fxb or 164
		PostEffectApply("boss_distortion", "", {
			centerX = x1,
			centerY = y1,
			size = _boss.aura_alpha*200*lstg.scale_3d,
			color = Color(125,fxr,fxg,fxb),
			colorsize = _boss.aura_alpha*200*lstg.scale_3d,
			arg=1500*_boss.aura_alpha/128*lstg.scale_3d,
			timer = self.timer
        })
	end
	SetViewMode'world'
	--
end