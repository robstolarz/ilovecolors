--notes: add floodfill, 9patch surfaces, entities, 
local scale=scale or 2
lWidth,lHeight=320,240 --logical width, height
local lWidth,lHeight=lWidth,lHeight
Level= love.filesystem.load("luaComponents/Level.lua")()
JSON = love.filesystem.load("luaComponents/JSON.lua")() --apologies for laziness
--level = Level.fromFile("levels/other.json")
x,y=1000,1000
level = Level.fromWorldPos(x,y)
sb = level:makeSpriteBatch()
sb2 = level:makeSpriteBatch(2)
typestring=""
drawtile=0
guistring="Press Enter to change tile number | "..drawtile
editmode = 0
clsncolors = {{0xFF,0xFF,0x00},{0x00,0xFF,0xFF},{0xFF,0x00,0xFF}}
clsnletters = {"S","U"}
font = love.graphics.newFont()
love.graphics.setFont(font)

function love.draw()
	love.graphics.push()
	mousex,mousey=love.mouse.getX()*1/scale,love.mouse.getY()*1/scale
	--camera:set()
	love.graphics.setColor(0xBE,0xE0,0xE5)
	love.graphics.rectangle('fill',0,0,love.graphics.getWidth(),love.graphics.getHeight())
	love.graphics.setColor(0xFF,0xFF,0xFF)
	love.graphics.scale(scale)
	if sb2 then love.graphics.draw(sb2) end
	love.graphics.draw(sb)
	love.graphics.pop()
	if editmode==1 then 
		love.graphics.print("Collision editing",0,0)
		love.graphics.push()
		love.graphics.scale(scale)
		for _x,l in pairs(level.collision) do
			for _y,t in pairs(l) do
				if t>0 then
					local x,y=_x*level.tilesize,_y*level.tilesize
					love.graphics.setColor(unpack(clsncolors[t]or{0x00,0x00,0x00}))
					love.graphics.line(x,y,x+level.tilesize,y,x+level.tilesize,y+level.tilesize,x,y+level.tilesize,x,y)
					--draw diagonal lines for shadelike
					for i=0,level.tilesize,4 do
						love.graphics.line(x,y+i,x+i,y)
						love.graphics.line(x+level.tilesize,y-i+level.tilesize,x-i+level.tilesize,y+level.tilesize)
					end
					--draw letter if available
					if clsnletters[t] then
						love.graphics.setColor(0x00,0x00,0x00)
						love.graphics.print(clsnletters[t],x+level.tilesize/scale-font:getWidth(clsnletters[t])/scale,y+level.tilesize/scale-font:getHeight()/scale)
					end
				end
			end
		end	
		love.graphics.pop()
		love.graphics.setColor(0xFF,0xFF,0xFF)
	else
		love.graphics.push()
		love.graphics.scale(scale)
		love.graphics.drawq(
			level.texture,
			love.graphics.newQuad(
				drawtile*level.tilesize%level.texture:getWidth(),
				level.tilesize*math.floor(drawtile*level.tilesize/level.texture:getWidth()),
				level.tilesize,
				level.tilesize,
				level.texture:getWidth(),
				level.texture:getHeight()
			), math.floor(mousex-level.tilesize/scale), math.floor(mousey-level.tilesize/scale))
		love.graphics.pop()
	end
	love.graphics.print(guistring, 0, (lHeight*scale)-(font:getHeight()))
	if editmode == 2 then
		love.graphics.print("Editing secondary image layer",0,0)
	end
	if love.keyboard.isDown("t") then
		love.graphics.push()
		love.graphics.scale(scale)
		love.graphics.draw(editmode == 2 and level.texture2 or level.texture) --at 0,0 for picker
		love.graphics.pop()
		if(love.mouse.isDown("l")) then
			drawtile=tonumber(math.floor(mousey/level.tilesize)*math.floor(level.texture:getWidth()/level.tilesize)+math.floor(mousex/level.tilesize))
		end
	elseif love.mouse.isDown("l") then
		xblock=math.floor(mousex/level.tilesize)
		yblock=math.floor(mousey/level.tilesize)
		guistring = xblock..", "..yblock
		
		if editmode==1 then
			if not level.collision[xblock] then level.collision[xblock] = {} end
			level.collision[xblock][yblock]=drawtile
		elseif editmode==2 then
			if not level.tiles2[xblock] then level.tiles2[xblock] = {} end
			level.tiles2[xblock][yblock]=drawtile
		else
			if not level.tiles[xblock] then level.tiles[xblock] = {} end
			level.tiles[xblock][yblock]=drawtile
		end
		sb=level:makeSpriteBatch()
		sb2=level:makeSpriteBatch(2)
	end
	love.graphics.setColor(0xFF,0xFF,0xFF,0x80)
	love.graphics.print("This alpha version is not necessarily representative of the final product",0,love.graphics.getHeight()-defaultfont:getHeight())
end
function love.keypressed(key,unicode)
	if typing=="num" then
		if unicode>47 and unicode<58 then
			typestring = typestring .. string.char(unicode)
			guistring="Tile: "..typestring
		elseif unicode==13 then
			drawtile=tonumber(typestring)or drawtile
			typing = ""
			guistring="Press Enter to change tile number | "..drawtile.." | "..x..", "..y
		end
	elseif typing=="file" then
		if unicode==13 then
			guistring="Saved as "..typestring
			level:toFile(typestring)
			typing = ""
		elseif unicode==64 then
			if love.filesystem.isFile(typestring) then
				level = Level.fromFile(typestring)
				guistring="loaded file "..typestring
			end
			typing = ""
			sb = level:makeSpriteBatch()
		elseif unicode>31 and unicode<127 then
			typestring = typestring .. string.char(unicode)
			guistring="File: "..typestring
		end
	else
		typestring=""
		if unicode==13 then
			typing = "num"
			guistring="Tile: "..typestring
		elseif unicode==102 then
			typing = "file"
			guistring="File: "..typestring
		elseif unicode==99 then
			editmode = editmode+1
			if editmode>2 or (editmode>1 and not texture2) then editmode=0 end
		elseif unicode==70 then
			love.filesystem.mkdir("/levels")
			typestring="/levels/"..x..","..y..".json"
			guistring="Saved as "..typestring
			level:toFile(typestring)
		else
			local keys = {
				up = function() level,x,y=level.fromWorldPos(x,y-1) end,
				down = function() level,x,y=level.fromWorldPos(x,y+1) end,
				left = function() level,x,y=level.fromWorldPos(x-1,y) end,
				right= function() level,x,y=level.fromWorldPos(x+1,y) end
			}
			for k,v in pairs(keys) do if love.keyboard.isDown(k) then keys[k]();sb = level:makeSpriteBatch();sb2 = level:makeSpriteBatch(2);guistring="loaded level "..x..", "..y end end
		end
	end
end