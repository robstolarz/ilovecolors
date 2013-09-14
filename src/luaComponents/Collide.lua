--<deniska>
		if (not player.onGround)  then
			player.vy -= gravity * dt
			player.y += player.vy * dt
			
			--check if player hits ceilings
			if (level:getCollisionAtPoint(math.floor( (player.lx + 0.01f)), math.floor( player.uy)) or
					level:getCollisionAtPoint(math.floor( (player.rx - 0.01f)), math.floor( player.uy)))  then
				player.vy = 0
				player.y = tonumber( (math.floor(player.uy) - player.height)) - 0.01f
			 end
			--check if player is on ground
			if (level:getCollisionAtPoint(math.floor( (player.lx + 0.01f)), math.floor( player.y)) or
					level:getCollisionAtPoint(math.floor( (player.rx - 0.01f)), math.floor( player.y)))  then
				player.onGround = true
				player.y = tonumber( math.ceil(player.y))
				player.vy = 0
			 end
		 end
		--check if player is in air
		if (not level:getCollisionAtPoint(math.floor( player.lx), math.floor( (player.y - 0.01))) and
				not level:getCollisionAtPoint(math.floor( player.rx), math.floor( (player.y - 0.01))))  then
			player.onGround = false
		 end
		player.x += player.vx * dt
		--check if player hits left or right walls
		if ((level:getCollisionAtPoint(math.floor( player.rx), math.floor( player.y)) or
				level:getCollisionAtPoint(math.floor( player.rx), math.floor( player.uy)) or
				level:getCollisionAtPoint(math.floor( player.rx), math.floor( player.my))) and
				player.vx >= 0)  then
			player.vx = 0
			player.x = tonumber( (math.floor(player.rx) - player.width / 2))
		 end
		if ((level:getCollisionAtPoint(math.floor( player.lx), math.floor( player.y)) or
				level:getCollisionAtPoint(math.floor( player.lx), math.floor( player.uy) )or
				level:getCollisionAtPoint(math.floor( player.lx), math.floor( player.my)) )and
				player.vx <= 0)  then
			player.vx = 0
			player.x = tonumber( (math.ceil(player.lx) + player.width / 2))
		 end