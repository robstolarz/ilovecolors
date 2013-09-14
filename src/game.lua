local scale=scale or 2
lWidth,lHeight=320,240 --logical width, height
local lWidth,lHeight=lWidth,lHeight
love.graphics.setMode(lWidth*scale,lHeight*scale,false,false)
love.graphics.setDefaultImageFilter("linear","nearest") --you'll be ok
local Level= love.filesystem.load("luaComponents/Level.lua")()
JSON = love.filesystem.load("luaComponents/JSON.lua")() --apologies for laziness
local level = Level.fromWorldPos(1000,1000)
local sb = level:makeSpriteBatch()
local sb2 = level:makeSpriteBatch(2)

local tolevel=nil
api = {
	switchlevel = function(x,y,preserve)
		tolevel={x,y,preserve}
	end,
	trace = function(self,x,y)
		local l={}
		for v,_ in pairs(entities) do
			if type(v.testcollision)=="function" then
				if v:testcollision(self,ax,ay,bx,by) then
					l[v]=true
				end
			end
		end
	end,
	isinbox = function(x,y,ax,ay,bx,by)
		return x>ax and x<bx and y>ay and y<by
	end
}

scriptables = {} --TODO: sandbox this? maybe?
for _,script in ipairs(love.filesystem.enumerate("/entityscript")) do
	if string.find(script,"%.lua$") then
		print(script)
		scriptables[script]=setmetatable(love.filesystem.load("/entityscript/"..script)(),{__index=api})
	end
end
entities = level:loadEntities(scriptables,api)

function queuedlevelswitch(x,y,preserve)
	level=level.fromWorldPos(x,y)
	entities={}
	if preserve then
		entities[preserve]=true
	end
	for v,_ in pairs(level:loadEntities(scriptables)) do
		entities[v]=true
	end
	sb = level:makeSpriteBatch()
	sb2 = level:makeSpriteBatch(2)
end

function love.draw()
	love.graphics.push()
	love.graphics.scale(scale)
	love.graphics.setColor(0xBE,0xE0,0xE5)
	love.graphics.rectangle('fill',0,0,love.graphics.getWidth(),love.graphics.getHeight())
	--love.graphics.setColor(0xFF,0xFF,0xFF,0x40)
	--player:draw()
	love.graphics.setColor(0xFF,0xFF,0xFF)
	if sb2 then love.graphics.draw(sb2) end
	love.graphics.draw(sb)
	
	for v,_ in pairs(entities) do
		v:draw()
		love.graphics.setColor(0xFF,0xFF,0xFF)
	end
	
	love.graphics.pop()
	love.graphics.setColor(0xFF,0xFF,0xFF,0xCC)
	love.graphics.print("This alpha version is not necessarily representative of the final product",0,love.graphics.getHeight()-defaultfont:getHeight())
end
function love.update(dt)
	if tolevel then 
		queuedlevelswitch(unpack(tolevel))
		tolevel=nil
	end
	if dt>0.018 then return end
	local l={}
	for v,_ in pairs(entities) do
		v:tick(dt,level,entityapi)
		if v.remove then --if the object asks to be removed, queue it
			l[v]=true
		end
	end
	for v,_ in pairs(l) do --then remove it afterwards
		entities[v]=nil --I use this queue thing because even tho it takes more memory, it takes waaay less iteration/frame on usual case
	end
end