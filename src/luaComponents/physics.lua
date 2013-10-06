--[[
	PHYSICS LIBRARY THING
	WRITTEN BY MAURICE GUEGAN FOR MARI0
	DON'T STEAL MY SHIT
	Licensed under the same license as the game itself.
]]--

--MASK REFERENCE LIST

function physicsupdate(dt,lobjects)
	for j, w in pairs(lobjects) do
		if j ~= "tile" then
			for i, v in pairs(w) do
				if v.static == false and v.active then
					--GRAVITY
					v.speedy = v.speedy + (v.gravity or gravity)*dt
					if v.speedy > maxyspeed then
						v.speedy = maxyspeed
					end
					
					--COLLISIONS ROFL
					local horcollision = false
					local vercollision = false
					
					--VS OTHER OBJECTS
					for h, u in pairs(lobjects) do
						local hor, ver = handlegroup(i, h, u, v, j, dt, passed)
						if hor then
							horcollision = true
						end
						if ver then
							vercollision = true
						end
					end
					
					--Move the object
					if vercollision == false then
						v.y = v.y + v.speedy*dt
						if v.gravity then
							if v.speedy == v.gravity*dt and v.startfall then
								v:startfall(i)
							end
						else
							if v.speedy == gravity*dt and v.startfall then
								v:startfall(i)
							end
						end
					end
					
					if horcollision == false then
						v.x = v.x + v.speedx*dt
					end
				end
			end
		end
	end
end

function handlegroup(i, h, u, v, j, dt, passed)
	local horcollision = false
	local vercollision = false
	for g, t in pairs(u) do
		--    Same object?          Active                 Not masked
		if (i ~= g or j ~= h) and t.active and (v.mask == nil or v.mask[t.category] ~= true) and (t.mask == nil or t.mask[v.category] ~= true) then
			local collision1, collision2 = checkcollision(v, t, h, g, j, i, dt, passed)
			if collision1 then
				horcollision = true
			elseif collision2 then
				vercollision = true
			end
		end
	end
	
	return horcollision, vercollision
end

function checkcollision(v, t, h, g, j, i, dt, passed) --v: b1table | t: b2table | h: b2type | g: b2id | j: b1type | i: b1id
	local hadhorcollision = false
	local hadvercollision = false
	
	if true then --preliminary check!
		--check if it's a passive collision (Object is colliding anyway)
		if not passed and aabb(v.x, v.y, v.width, v.height, t.x, t.y, t.width, t.height) then --passive collision! (oh noes!)
			if passivecollision(v, t, h, g, j, i, dt) then
				hadvercollision = true
			end
			
		elseif aabb(v.x + v.speedx*dt, v.y + v.speedy*dt, v.width, v.height, t.x, t.y, t.width, t.height) then
			if aabb(v.x + v.speedx*dt, v.y, v.width, v.height, t.x, t.y, t.width, t.height) then --Collision is horizontal!
				if horcollision(v, t, h, g, j, i, dt) then
					hadhorcollision = true
				end
				
			elseif aabb(v.x, v.y+v.speedy*dt, v.width, v.height, t.x, t.y, t.width, t.height) then --Collision is vertical!
				if vercollision(v, t, h, g, j, i, dt) then
					hadvercollision = true
				end
				
			else 
				--We're fucked, it's a diagonal collision! run!
				--Okay actually let's take this slow okay. Let's just see if we're moving faster horizontally than vertically, aight?
				local grav = gravity
				if self and self.gravity then
					grav = self.gravity
				end
				if math.abs(v.speedy-grav*dt) < math.abs(v.speedx) then
					--vertical collision it is.
					if vercollision(v, t, h, g, j, i, dt) then
						hadvercollision = true
					end
				else 
					--okay so we're moving mainly vertically, so let's just pretend it was a horizontal collision? aight cool.
					if horcollision(v, t, h, g, j, i, dt) then
						hadhorcollision = true
					end
				end
			end
		end
	end
	
	return hadhorcollision, hadvercollision
end

function passivecollision(v, t, h, g, j, i, dt)
	if v.passivecollide then
		v:passivecollide(h, t)
		if t.passivecollide then
			t:passivecollide(j, v)
		end
	else
		if v.floorcollide then
			if v:floorcollide(h, t, dt) ~= false then
				if v.speedy > 0 then
					v.speedy = 0
				end
				v.y = t.y - v.height
				return true
			end
		else
			if v.speedy > 0 then
				v.speedy = 0
			end
			v.y = t.y - v.height
			return true
		end
	end
	
	return false
end

function horcollision(v, t, h, g, j, i, dt)
	if v.speedx < 0 then
		--move object RIGHT (because it was moving left)
		
		if t.rightcollide then
			if t:rightcollide(j, v) ~= false then
				if t.speedx and t.speedx > 0 then
					t.speedx = 0
				end
			end
		else
			if t.speedx and t.speedx > 0 then
				t.speedx = 0
			end
		end
		if v.leftcollide then
			if v:leftcollide(h, t) ~= false then
				if v.speedx < 0 then
					v.speedx = 0
				end
				v.x = t.x + t.width
				return true
			end
		else
			if v.speedx < 0 then
				v.speedx = 0
			end
			v.x = t.x + t.width
			return true
		end
	else
		--move object LEFT (because it was moving right)
		
		if t.leftcollide then
			if t:leftcollide(j, v) ~= false then
				if t.speedx and t.speedx < 0 then
					t.speedx = 0
				end
			end
		else
			if t.speedx and t.speedx < 0 then
				t.speedx = 0
			end
		end
		
		if v.rightcollide then
			if v:rightcollide(h, t) ~= false then
				if v.speedx > 0 then
					v.speedx = 0
				end
				v.x = t.x - v.width
				return true
			end
		else
			if v.speedx > 0 then
				v.speedx = 0
			end
			v.x = t.x - v.width
			return true
		end
	end
	
	return false
end

function vercollision(v, t, h, g, j, i, dt)
	if v.speedy < 0 then
		--move object DOWN (because it was moving up)
		if t.floorcollide then
			if t:floorcollide(j, v) ~= false then
				if t.speedy and t.speedy > 0 then
					t.speedy = 0
				end
			end
		else
			if t.speedy and t.speedy > 0 then
				t.speedy = 0
			end
		end
		
		if v.ceilcollide then
			if v:ceilcollide(h, t) ~= false then
				if v.speedy < 0 then
					v.speedy = 0
				end
				v.y = t.y  + t.height
				return true
			end
		else
			if v.speedy < 0 then
				v.speedy = 0
			end
			v.y = t.y  + t.height
			return true
		end
	else					
		if t.ceilcollide then
			if t:ceilcollide(j, v) ~= false then
				if t.speedy and t.speedy < 0 then
					t.speedy = 0
				end
			end
		else
			if t.speedy and t.speedy < 0 then
				t.speedy = 0
			end
		end
		if v.floorcollide then
			if v:floorcollide(h, t, dt) ~= false then
				if v.speedy > 0 then
					v.speedy = 0
				end
				v.y = t.y - v.height
				return true
			end
		else
			if v.speedy > 0 then
				v.speedy = 0
			end
			v.y = t.y - v.height
			return true
		end
	end
	return false
end

function aabb(ax, ay, awidth, aheight, bx, by, bwidth, bheight)
	return ax+awidth > bx and ax < bx+bwidth and ay+aheight > by and ay < by+bheight
end

function checkrect(x, y, width, height, list, statics)
	local out = {}
	
	local inobj
	
	if type(list) == "table" and list[1] == "exclude" then
		inobj = list[2]
		list = "all"
	end

	for i, v in pairs(objects) do
		local contains = false
		
		if list and list ~= "all" then			
			for j = 1, #list do
				if list[j] == i then
					contains = true
				end
			end
		end
		
		if list == "all" or contains then
			for j, w in pairs(v) do
				if statics or w.static ~= true or list ~= "all" then
					local skip = false
					if inobj then
						if w.x == inobj.x and w.y == inobj.y then
							skip = true
						end
						--masktable
						if (inobj.mask ~= nil and inobj.mask[w.category] == true) or (w.mask ~= nil and w.mask[inobj.category] == true) then
							skip = true
						end
					end
					if not skip then
						if w.active then
							if aabb(x, y, width, height, w.x, w.y, w.width, w.height) then
								table.insert(out, i)
								table.insert(out, j)
							end
						end
					end
				end
			end
		end
	end
	
	return out
end
