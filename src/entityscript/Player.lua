Player = {}
Player.__index=Player
function Player.new(x,y)
		local new = setmetatable({},Player)
		new.x=x
		new.y=y
		new.vY=0
		new.constX=0
		new.spriteimg=love.graphics.newImage("/entityimg/dapperman.png")
		new.tW=5
		new.tH=14
		new.cW=5 --collision width, used to get edge blocks
		new.cH=13
		--suggested move distance
		new.mdX=0
		new.mdY=0
		new.anim={
			standing={
				none={
					{0,0}
				}
			},
			walking={
				none={
					{1,0},{2,0}
				}
			}
		}
		new.animstate="standing"
		new.powerupstate="none"
		new.animframe=1	
		new.direction=1
		new.lockcontrol=false
		new.dataquad=love.graphics.newQuad(0,0,new.tW,new.tH,new.spriteimg:getWidth(),new.spriteimg:getHeight())
		return new
	end
function Player:draw()
	if math.floor(self.animframe)>#self.anim[self.animstate][self.powerupstate] then
		self.animframe=1
	end
	self.dataquad:setViewport(
		self.anim[self.animstate][self.powerupstate][math.floor(self.animframe)][1]*self.tW,
		self.anim[self.animstate][self.powerupstate][math.floor(self.animframe)][2]*self.tH,
		self.tW,self.tH,self.spriteimg:getWidth(),self.spriteimg:getHeight())
	love.graphics.drawq(self.spriteimg,self.dataquad,math.floor(self.x)+self.tW/2,self.y,0,self.direction,1,self.tW/2,0)
end
function sign(x)
	if x>0 then return 1 elseif x<0 then return -1 else return 0 end
end
function Player:tick(dt,level) 
	--gravity first
	self.vY=math.min(self.vY+1250*dt,10000)
	self.mdY=self.mdY+math.min(self.vY,128*16)*dt
	
	local ax,ay,bx,by = self.x,self.y,self.x+self.cW,self.y+self.cH
	
	if ((level:collisionAtPoint(ax,ay-1)==0)
			and(level:collisionAtPoint(bx,ay-1)==0))
		and not((level:collisionAtPoint(ax,by+1)==0)
			and(level:collisionAtPoint(bx,by+1)==0))
		and self.vY>=0
	then
		if love.keyboard.isDown(" ") then
			self.vY=-300
		elseif self.vY>=0 then
			self.lockcontrol=false
		end
	end
	
	if love.keyboard.isDown("left") then
		if not self.lockcontrol then self.mdX=self.mdX-16*6*dt end
	end
	if love.keyboard.isDown("right") then
		if not self.lockcontrol then self.mdX=self.mdX+16*6*dt end
	end

	if self.lockcontrol then
		self.mdX=self.constX*dt*sign(self.mdX)+self.mdX
	end
	
	if self.x<self.cW then
		self.switchlevel(level.x-1,level.y,self,"Player")
		self.x=lWidth
	elseif self.x>(lWidth or 320) then
		self.switchlevel(level.x+1,level.y,self,"Player")
		self.x=0
	elseif self.y<-self.cH then
		self.switchlevel(level.x,level.y-1,self,"Player")
		self.y=(lHeight or 240)
	elseif self.y>(lHeight or 240) then
		self.switchlevel(level.x,level.y+1,self,"Player")
		self.y=0
	end

	
	if math.abs(self.mdX)>1 then 
		self.animstate="walking" 
		self.direction=sign(self.mdX)
	else
		self.animstate="standing"
	end
	
	local mDir = sign(self.mdY)
	local pY=0
	
	--iterate direction from player
	while math.abs(self.mdY)>1 do
		ax,ay,bx,by = self.x,self.y,self.x+self.cW,self.y+self.cH
		if mDir==-1 then
			pY=ay
		else
			pY=by
		end
		if(mDir==-1 and ((level:collisionAtPoint(ax,mDir+pY)==1)or(level:collisionAtPoint(bx,mDir+pY)==1)))or(mDir==1 and ((level:collisionAtPoint(ax,mDir+pY)~=0)or(level:collisionAtPoint(bx,mDir+pY)~=0))) then 
			self.mdY=0
			self.vY=0
			self.constX=0
			break
		end
		self.y=self.y+mDir
		self.mdY=self.mdY-mDir
	end
	
	--safe movement
	mDir = sign(self.mdX)
	p=0

	--iterate direction from player
	while math.abs(self.mdX)>1 do
		ax,ay,bx,by = self.x,self.y,self.x+self.cW,self.y+self.cH
		if mDir==-1 then
			p=ax
		else
			p=bx
		end
		if(level:collisionAtPoint(mDir+p,ay)~=0)or(level:collisionAtPoint(mDir+p,by)~=0) then 
			self.mdX=0
			self.constX=0
			break
		end
		self.x=self.x+mDir
		self.mdX=self.mdX-mDir
	end
	
	
	self.animframe=(self.animframe+dt*7)
	if math.floor(self.animframe)>#self.anim[self.animstate][self.powerupstate] then
		self.animframe=1
	end
end

return Player