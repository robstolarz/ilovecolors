local LTR = {}
LTR.__index=LTR
function LTR.new(x,y)
	local new = setmetatable({},LTR)
	new.x=x
	new.y=y
	new.vY=0
	new.spriteimg=love.graphics.newImage("/entityimg/LTR.png")
	new.tW=25
	new.tH=30
	new.cW=20 --collision width, used to get edge blocks
	new.cH=27
	--suggested move distance
	new.mdX=0
	new.mdY=0
	new.anim={standing={{0,0}},walking={{0,0},{1,0},{2,0},{3,0},{4,0},{5,0},{6,0},{7,0}}}
	new.animstate="walking"
	new.animframe=1	
	new.direction=1
	new.timer=0
	new.dataquad=love.graphics.newQuad(0,0,new.tW,new.tH,new.spriteimg:getWidth(),new.spriteimg:getHeight())
	return new
end
function LTR:draw()
	if math.floor(self.animframe)>#self.anim[self.animstate] then
		self.animframe=1
		self.timer=1.2
	end
	self.dataquad:setViewport(
		self.anim[self.animstate][math.floor(self.animframe)][1]*self.tW,
		self.anim[self.animstate][math.floor(self.animframe)][2]*self.tH,
		self.tW,self.tH,self.spriteimg:getWidth(),self.spriteimg:getHeight())
	love.graphics.drawq(self.spriteimg,self.dataquad,math.floor(self.x+(self.direction==-1 and self.tW or 0)),math.floor(self.y),0,self.direction,1)
end
function LTR:tick(dt,level)
	self.timer=self.timer-dt
	if self.timer>0 then return end
	self.mdX=self.direction*dt*16*2+self.mdX
	local mDir = sign(self.mdX)
	local p=0
	local ax,ay,bx,by
	while math.abs(self.mdX)>1 do
		ax,ay,bx,by = self.x,self.y,self.x+self.cW,self.y+self.cH
		if mDir==-1 then
			p=ax
		else
			p=bx
		end
		if(level:collisionAtPoint(mDir+p,ay)~=0)or(level:collisionAtPoint(mDir+p,by)~=0)or(level:collisionAtPoint(mDir+p,by+3)~=1) then 
			self.mdX=0
			self.direction=-self.direction
			break
		end
		self.x=self.x+mDir
		self.mdX=self.mdX-mDir
	end
	
	self.animframe=(self.animframe+dt*9)
end
return LTR