Player = {}
Player.__index=Player
function Player.make(x,y,spriteimg)
		local new = setmetatable({},Player)
		new.x=x
		new.y=y
		new.vY=0
		new.spriteimg=love.graphics.newImage(spriteimg)
		new.tW=5
		new.tH=14
		new.cW=5 --collision width, used to get edge blocks
		new.cH=14
		--suggested move distance
		new.mdX=0
		new.mdY=0
		new.anim={standing={{0,0}},walking={{1,0},{2,0}}}
		new.animstate="standing"
		new.animframe=1
		new.dataquad=love.graphics.newQuad(0,0,new.tW,new.tH,new.spriteimg:getWidth(),new.spriteimg:getHeight())
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
	local ax,ay,bx,by = self.x-1,self.y,self.x+self.cW+1,self.y+self.cH-1
	
	local keys = {
		left=function() self.mdX=self.mdX-16*5*dt end,
		right=function()self.mdX=self.mdX+16*5*dt end
	}
	keys[" "]=function()
		if ((level:collisionAtPoint(ax,ay-1)==0)and(level:collisionAtPoint(bx,ay-1)==0))and not((level:collisionAtPoint(ax,by+1)==0)and(level:collisionAtPoint(bx,by+1)==0)) then
			self.vY=-335
		end
	end
	
	for k,v in pairs(keys) do if love.keyboard.isDown(k) then keys[k]() end end
	
	local mDir = sign(self.mdY)
	local p=0
	if mDir==-1 then
		p=ay
	else
		p=by
	end
	--iterate direction from player
	while math.abs(self.mdY)>1 do
		if(level:collisionAtPoint(ax,mDir+p)~=0)or(level:collisionAtPoint(bx,mDir+p)~=0) then 
			self.mdY=0
			self.vY=0
			break
		end
		self.y=self.y+mDir
		self.mdY=self.mdY-mDir
	end
	
	--push out
	--TODO: URGENT: FIX EXITING BLOCK IF LEGS ARE IN IT WHEN BELOW BLOCK (use round)
	--NOT FIXED BY MODULUS, HONESTLY A LOT OF STUFF IS BROKEN IN THIS ALGORITHM (and by%level.tilesize<5)
	while ((level:collisionAtPoint(ax,by)~=0)or(level:collisionAtPoint(bx,by)~=0)) do
		self.y=self.y-1
		by=self.y+self.cH-1
	end
	
	--safe movement
	mDir = sign(self.mdX)
	p=0
	if mDir==-1 then
		p=ax
	else
		p=bx
	end
	--iterate direction from player
	while math.abs(self.mdX)>1 do
		if(level:collisionAtPoint(mDir+p,ay)~=0)or(level:collisionAtPoint(mDir+p,by)~=0) then 
			self.mdX=0 
			break
		end
		self.x=self.x+mDir
		self.mdX=self.mdX-mDir
	end
	--other way now
	--gravity first
	self.vY=math.min(self.vY+1500*dt,100000)
	self.mdY=self.mdY+self.vY*dt
	
	--let's a-go
	mDir = sign(self.mdY)
	p=0
	if mDir==-1 then
		p=ay
	else
		p=by
	end
	--iterate direction from player
	while math.abs(self.mdY)>1 do
		if(level:collisionAtPoint(ax,mDir+p)~=0)or(level:collisionAtPoint(bx,mDir+p)~=0) then 
			self.mdY=0
			self.vY=0
			break
		end
		self.y=self.y+mDir
		self.mdY=self.mdY-mDir
	end
	
	self.animstate="walking" --TODO: fix crash bug you fucker
	self.animframe=(self.animframe+dt*6.66)
	if math.floor(self.animframe)>#self.anim[self.animstate] then
		self.animframe=1
	end
end


return Player