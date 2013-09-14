--Level component
Level = {}
Level.__index = Level
function zerotoone(array)
	local l={}
	for place,p in pairs(array) do
		if type(place)=="number" then 
			if type(p)=="table" then l[place+1]=zerotoone(p) else
				l[place+1]=p
			end
		end
	end
	return l
end
function onetozero(array)
	local l={}
	for place,p in pairs(array) do
		if type(place)=="number" then 
			if type(p)=="table" then l[place-1]=onetozero(p) else
				l[place-1]=p
			end
		end
	end
	return l
end
function Level.fromWorldPos(x,y)
	return Level.fromFile("/levels/"..x..","..y..".json",x,y),x,y
end
function Level.fromFile(file,x,y)
	local parsed = nil
	if love.filesystem.isFile(file) then
		parsed = JSON:decode(love.filesystem.read(file))
	else
		parsed = JSON:decode(love.filesystem.read("levels/default level.json"))
	end
	local new = setmetatable({}, Level)
	new.levelname=file
	new.x=x or 1000
	new.y=y or 1000
	new.backgroundname = parsed.background
	new.texturename = parsed.texture
	new.texturename2 = parsed.texture2
	new.texture = love.graphics.newImage("/tilesets/"..new.texturename..".png")
	if new.texturename2 then
		new.texture2 = love.graphics.newImage("/tilesets/"..new.texturename2..".png")
	end
	new.tilesize = parsed.tilesize
	new.entities = parsed.entities or {}
	new.tiles = onetozero(parsed.tiles or {})
	new.tiles2 = onetozero(parsed.tiles2 or {})
	new.collision = onetozero(parsed.collision or {})
	for i=0,math.floor((lWidth or 320)/new.tilesize)-1 do
		new.tiles[i] = new.tiles[i] or {}
		new.collision[i] = new.collision[i] or {}
		new.tiles2[i] = new.tiles2[i] or {}
		for j=0,math.floor((lHeight or 240)/new.tilesize)-1 do
			new.tiles[i][j] = new.tiles[i][j] or 0
			new.collision[i][j] = new.collision[i][j] or 0
			new.tiles2[i][j] = new.tiles2[i][j] or 0
		end
	end
	return new
end
function Level:makeSpriteBatch(which)
	local sb = nil
	if which == 2 then
		if self.texture2 then
			sb = love.graphics.newSpriteBatch(self.texture2)
		else
			return nil
		end	
	else
		sb = love.graphics.newSpriteBatch(self.texture)
	end
	local q = love.graphics.newQuad(0,0,1,1,
		self.texture:getWidth(),
		self.texture:getHeight()
	)
	local width,height=lWidth/self.tilesize,lHeight/self.tilesize
	for n,i in pairs(which==2 and self.tiles2 or self.tiles) do
		if n>=0 and n<width then
			for m,j in pairs(i) do
				if j>0 and m>=0 and m<height then
				--n,m is x,y on screen
				--j*tilesize%texture.width,j*tilesize/texture.width
				--don't batch empty tile (j<=0)
					q:setViewport(
						j*self.tilesize%self.texture:getWidth(),
						self.tilesize*math.floor(j*self.tilesize/self.texture:getWidth()),
						self.tilesize,
						self.tilesize
					)
					sb:addq(q, n*self.tilesize, m*self.tilesize)
				end
			end
		end
	end
	return sb
end
function Level:loadEntities(loadables,api)
	local entities = {}
	for _,v in pairs(self.entities) do
		print(v[1],unpack(v[2]))
		entities[loadables[v[1]].new(unpack(v[2]))]=true --construct each entity: ["Player.lua",[160,120,"entities/dapperman.png"]]
		--it looks horrible; that's cause it's an unordered set :D
	end
	return entities
end
function Level:toFile(filename)
	--assert(self.texture&&self.tilesize&&self.entities&&self.tiles&&filename,"something not provided, level not saved")
	local thing = {
		tiles = zerotoone(self.tiles),
		tiles2 = zerotoone(self.tiles2),
		tilesize = self.tilesize,
		entities = self.entities,
		texture = self.texturename,
		texture2 = self.texturename2,
		background = self.backgroundname,
		collision = zerotoone(self.collision)
	}
	love.filesystem.write(filename,JSON:encode(thing))
end
function Level:collisionAtPoint(x,y)
	return self.collision[math.floor(x/self.tilesize)][math.floor(y/self.tilesize)] or 0
end
return Level