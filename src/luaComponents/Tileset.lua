local Tileset = {}
Tileset.__index = Tileset
function Tileset.fromFile(file)
	parsed = JSON:decode(love.filesystem.load("/tilesets/"..file.."/"..file..".json"))
	new = setmetatable({}, Tileset)
	new.texturename = "/tilesets/"..file.."/"..file..".png"
	new.texture = love.graphics.newImage(new.texturename)
	new.tilesize = parsed.tilesize
	new.collisiondata=parsed.collisiondata
end
function Tileset:toFile(file)
	love.filesystem.write(file,JSON:encode({
		new.tilesize = self.tilesize,
		new.collisiondata = self.collisiondata
	}))
end
return Tileset