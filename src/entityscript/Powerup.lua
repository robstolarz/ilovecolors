local Powerup = {}
Powerup.__index=Powerup

function Powerup.new(x,y,which)
	local new={}
	setmetatable(new,Powerup)
	if not api then error"no api"end
	new.api=api
	new.image=love.graphics.newImage("/entityimg/Powerup.png")
	new.drawquad = love.graphics.newQuad(which*9,0,9,8,new.image:getWidth(),new.image:getHeight())
	new.x=x
	new.y=y
	return new
end

function Powerup:draw()
	love.graphics.drawq(self.image,self.drawquad,self.x,self.y)
end

function Powerup:tick(dt)
	self.timer=dt+(self.timer or 0)
end
return Powerup