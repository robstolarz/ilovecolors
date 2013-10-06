Player = {}
Player.__index=Player
Player.anim={
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
Player.spriteimg=love.graphics.newImage("/entityimg/dapperman.png")
function Player.new(x,y)
	local new = setmetatable({},Player)
	new.x=x
	new.y=y
	new.speedx=0
	new.speedy=0
	new.tW=5
	new.tH=14
	new.width=5
	new.height=14
	new.static = false
	new.active = true
	new.mask = {}
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
function Player:tick(dt,level) 
	
	
	if love.keyboard.isDown("left") then
		self.speedx = -16*5
	elseif love.keyboard.isDown("right") then
		self.speedx = 16*5
	else
		self.speedx = 0
	end
	if love.keyboard.isDown("up") and self.floored then
		self.speedy = -140
		self.floored = false
	end
	
	
	
	if self.x<0 then
		self.switchlevel(level.x-1,level.y,self,"Player")
		self.x=lWidth
	elseif self.x>(lWidth or 320) then
		self.switchlevel(level.x+1,level.y,self,"Player")
		self.x=0
	elseif self.y<0 then
		self.switchlevel(level.x,level.y-1,self,"Player")
		self.y=(lHeight or 240)
	elseif self.y>(lHeight or 240) then
		self.switchlevel(level.x,level.y+1,self,"Player")
		self.y=0
	end

	
	--[[if math.abs(self.mdX)>1 then 
		self.animstate="walking" 
		self.direction=sign(self.mdX)
	else
		self.animstate="standing"
	end]]--

	self.animframe=(self.animframe+dt*7)
	if math.floor(self.animframe)>#self.anim[self.animstate][self.powerupstate] then
		self.animframe=1
	end
end

function Player:ceilcollide(a, b)
	if not b then return true end
	return b.collisiontype==1
end

function Player:passivecollide(a, b)
	return false
end

function Player:floorcollide(a,b)
	self.floored = true
end
function Player:startfall(i)
	self.floored = false
end
return Player