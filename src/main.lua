defaultfont = love.graphics.newFont()
titlefont = love.graphics.newFont("Vera.ttf",love.graphics.getHeight()/5)
scale=2
if love.filesystem.exists("revision") then
	revisionnum = tonumber(love.filesystem.read("revision"))
end
function love.draw()
	love.graphics.setFont(titlefont)
	love.graphics.setColor(0xFF,0xFF,0xFF,0x20)
	love.graphics.print("i love colors",love.graphics.getWidth()/2-titlefont:getWidth("i love colors")/2,love.graphics.getHeight()/2-titlefont:getHeight()/2)
	love.graphics.setColor(0xFF,0xFF,0xFF)
	love.graphics.setFont(defaultfont)
	love.graphics.print("l for level editor\ng for game\ns to change scale (currently at "..scale..")",0,0)
	love.graphics.printf("Made by Rob Stolarz\nr"..(revisionnum or"Unknown"),0,love.graphics.getHeight()-defaultfont:getHeight()*2,love.graphics.getWidth(),"right")
	love.graphics.setColor(0xFF,0xFF,0xFF,0x20)
	love.graphics.print("This alpha version is not necessarily representative of the final product",0,love.graphics.getHeight()-defaultfont:getHeight())
end
function love.keypressed(key)
	if key=="l" then love.filesystem.load("levedit.lua")() end
	if key=="g" then love.filesystem.load("game.lua")() end
	if key=="m" then love.audio.play(bgm) end
	if key=="s" then 
		scale=scale+1
	end
end