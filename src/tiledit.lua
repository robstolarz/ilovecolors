JSON = love.filesystem.load("luaComponents/JSON.lua")()
Tileset = love.filesystem.load("luaComponents/Tileset.lua")()
function love.draw()
	mousex,mousey=love.mouse.getPosition()
	if love.mouse.isDown("l") and not showingtiles then
		xblock=math.floor(mousex/openlevel.tilesize)
		yblock=math.floor(mousey/openlevel.tilesize)
		if not openlevel.tiles[xblock] then 
			openlevel.tiles[xblock] = {}
		end
		guistring = xblock..", "..yblock
		openlevel.tiles[xblock][yblock]=drawtile
	end
	love.graphics.setColor(0,255,0)
	love.graphics.rectangle('fill',0,0,love.graphics.getWidth(),love.graphics.getHeight())
	love.graphics.setColor(255,255,255)
	love.graphics.drawq(
		openlevel.texture,
		love.graphics.newQuad(
			drawtile*openlevel.tilesize%openlevel.texture:getWidth(),
			openlevel.tilesize*math.floor(drawtile*openlevel.tilesize/openlevel.texture:getWidth()),
			openlevel.tilesize,
			openlevel.tilesize,
			openlevel.texture:getWidth(),
			openlevel.texture:getHeight()
		), mousex-openlevel.tilesize/2, mousey-openlevel.tilesize/2)
	
end