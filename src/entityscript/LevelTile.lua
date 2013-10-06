LevelTile = {}
LevelTile.__index=LevelTile
function LevelTile.new(x,y,size)
	new = setmetatable({},LevelTile)
	new.speedx = 0
	new.speedy = 0
	new.x = x
	new.y = y
	new.width = size
	new.height = size
	new.static = true
	new.active = true
	
	new.mask = {}
	return new
end
return LevelTile