Player = {}
Player.__index=Player
function Player.make(x,y,spriteimg)
		local new = setmetatable({},Player)
		new.x=x
		new.y=y
		new.vx=0
		new.vy=0
		new.spriteimg=love.graphics.newImage(spriteimg)
		new.tW=5
		new.tH=14
		new.width=5 --collision width, used to get corners
		new.height=14
		new.anim={standing={{0,0}},walking={{1,0},{2,0}}}
		new.animstate="standing"
		new.animframe=1
		new.dataquad=love.graphics.newQuad(0,0,new.tW,new.tH,new.spriteimg:getWidth(),new.spriteimg:getHeight())
		new.onGround=false
		return new
	end

--http://lua-users.org/lists/lua-l/2008-04/msg00432.html rounding TODO: credit?
function round(x)
	if x%2 ~= 0.5 then
		return math.floor(x+0.5)
	end
	return x-0.5
end
	
function Player:draw()
	if math.floor(self.animframe)>#self.anim[self.animstate] then
		self.animframe=1
	end
	self.dataquad:setViewport(self.anim[self.animstate][math.floor(self.animframe)][1]*self.tW,self.anim[self.animstate][math.floor(self.animframe)][2]*self.tH,self.tW,self.tH,self.spriteimg:getWidth(),self.spriteimg:getHeight())
	love.graphics.drawq(self.spriteimg,self.dataquad,math.floor(self.x),math.floor(self.y))
end
function lerp(a,b,t)
	return a + (b - a) * t
end
--delerp(fromX,toX,box1x+box1width+box2width
function delerp(a,b,c)
	return (c - a) / (b - a)
end
function sign(x)
	if x>0 then return 1 elseif x<0 then return -1 else return 0 end
end
function Player:tick(dt,level) 
	--local ax,ay,bx,by = self.x-1,self.y,self.x+self.cW+1,self.y+self.cH-1
	local x,y=self.x/16,self.y/16
	local lx,rx,uy,my = x-self.width/2,x+self.width/2,y+self.height,y+self.height/2
	
	local keys = {
		left=function() self.vx=self.vx-16*5*dt end,
		right=function()self.vx=self.vx+16*5*dt end
	}
	keys[" "]=function()
		if self.onGround then
			self.vy=-10
		end
	end
	
	for k,v in pairs(keys) do if love.keyboard.isDown(k) then keys[k]() end end
	--<deniska>, credit him
	if (not self.onGround) then
		self.vy = 9.6 * dt + self.vy
		y = self.vy * dt + y
		
		--check if player hits ceilings
		if (level:collisionAtPointBR(math.ceil((lx)), math.floor(uy)) or
				level:collisionAtPointBR(math.ceil((rx)), math.floor(uy))) then
			self.vy = 0
			y = tonumber((math.floor(uy) - self.height))
		end
		--check if player is on ground
		if (level:collisionAtPointBR(math.ceil((lx)), math.floor(y)) or
				level:collisionAtPointBR(math.ceil((rx)), math.floor(y))) then
			self.onGround = true
			y = tonumber(math.ceil(y))
			self.vy = 0
		end
	end
	--check if player is in air
	if (not level:collisionAtPointBR(math.ceil(lx), math.floor((y))) and
			not level:collisionAtPointBR(math.ceil(rx), math.floor((y)))) then
		self.onGround = false
	end
	x = self.vx * dt + x
	--check if player hits left or right walls
	if ((level:collisionAtPointBR(math.ceil(rx), math.ceil(y)) or
			level:collisionAtPointBR(math.ceil(rx), math.ceil(uy)) or
			level:collisionAtPointBR(math.ceil(rx), math.ceil(my))) and
			self.vx > 0) then
		self.vx = 0
		x = tonumber((math.ceil(rx) - self.width / 2))
	end
	if ((level:collisionAtPointBR(math.floor(lx), math.floor(y)) or
			level:collisionAtPointBR(math.floor(lx), math.floor(uy))or
			level:collisionAtPointBR(math.floor(lx), math.floor(my)))and
			self.vx < 0) then
		self.vx = 0
		x = tonumber((math.floor(lx) + self.width / 2))
	end
	
	self.x=x*16
	self.y=y*16
	
	self.animstate="walking" --TODO: fix crash bug you fucker
	self.animframe=(self.animframe+dt*6.66)
	if math.floor(self.animframe)>#self.anim[self.animstate] then
		self.animframe=1
	end
end


return Player