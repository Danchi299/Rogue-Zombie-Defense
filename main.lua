
require("controls")

	win   = love.window
	key   = love.keyboard
	fsys  = love.filesystem
	graph = love.graphics
	sound = love.sound
	audio = love.audio
	image = love.image
	tread = love.tread
	
	font  = graph.getFont() font:setFilter('nearest', 'nearest') -- font  = graph.newFont("arial.ttf", 64)
	fontHight = font:getHeight()
	
	str = string
	fmt = str.format 
	upr = str.upper
	lwr = str.lower

hiscore  = {0, 0, 0}
menu     = true
settings = false
diff    = 2
players = 1

title = "Rogue Zombie Defense"
win.setTitle(title)
icon = love.image.newImageData('icon.png')
win.setIcon(icon) 
icon = nil

LaserSprites = {
     [1]='/',
     [2]='|',
     [3]='\\',
     [4]='—',
     [6]='—',
     [7]='\\',
     [8]='|',
     [9]='/',
}
LaserMovement = {
	[1]='lasery = lasery + laserspeed * dt laserx = laserx - laserspeed * dt',			
	[2]='lasery = lasery + laserspeed * dt ',			
	[3]='lasery = lasery + laserspeed * dt laserx = laserx + laserspeed * dt',			
	[4]='laserx = laserx - laserspeed * dt',			
	[6]='laserx = laserx + laserspeed * dt',			
	[7]='lasery = lasery - laserspeed * dt laserx = laserx - laserspeed * dt',			
	[8]='lasery = lasery - laserspeed * dt',			
	[9]='lasery = lasery - laserspeed * dt laserx = laserx + laserspeed * dt',
}
LaserAngle = {
	[1] = { -5,  -5},
	[2] = {  0, -10},
	[3] = {  5,  -5},
	[4] = {-10,   0},
	[6] = { 10,   0},
	[7] = { -5,   5},
	[8] = {  0,  10},
	[9] = {  5,   5},
}

function pprint(text, x, y)
	text = tostring(text)
	local x, y = x - (font:getWidth(text)/2), y - (fontHight / 2)
	graph.print(text, x, y)
end

function addStats(text)
text = tostring(text)
	graph.print(text, 20, tempy)
	tempy = tempy + 20
end

function addInfo(text)
	text = tostring(text)
	local w = font:getWidth(text) + 20
	graph.print(text, width - w, tempx)
	tempx = tempx + 20
end

function lens(t)
	local i = 0
	for _ in pairs(t) do i=i+1 end
	return i
end

function distance(_1, _2)
	x1, y1, x2, y2 = _1[1], _1[2], _2[1], _2[2]
	return math.sqrt((x2 -x1)^2 + (y2 - y1)^2)
end

function isOut(t)
	local x, y = t[1], t[2]
	return (height < y or y < 0) or (width < x or x < 0)
end

function SpawnEnemie()
	
	local _ = function(x, y) 
		
		d1 = distance({x, y}, {p1[1], p1[2]})
		
		if p2[3] then
			d2 = distance({x, y}, {p2[1], p2[2]})
		else
			d2 = 101
		end
		
		return (d1 < 100 and d2 < 100)
		
	end
	
	x = math.random(0, width)
	y = math.random(0, height)
	while _(x, y) do
		x = math.random(0, width)
		y = math.random(0, height)
	end

	table.insert(enemies, {x, y})
end

function CalcProgress()
end

function love.load()
	players = players or 1
	width, height = graph.getDimensions()

	keylock = {}
	lasers  = {}
	enemies = {}
	
	mod = 5
	--       X        Y    isAlive
	p1 = {width/2, height/2, true}
	p2 = {-1000, -1000, false}
	if players == 2 then
		p1 = {(width/2)-mod, height/2, true}
		p2 = {(width/2)+mod, height/2, true}
	end
	
	angle = {4, 6}
	speed = 50
	laserspeed = 200
	score = 0
	dead = false
	
	progress = 0
	CalcProgress()

	for i=1,10 + diff*10 do
		SpawnEnemie()
	end
end

function love.update(dt)

	width, height = graph.getDimensions()

	tempy = 20
	tempx = 20
	
	-- not(a or b) is same as (not a and not b)\
	if not(p1[3] or p2[3]) then dead = true end
	if menu or dead then return 0 end

	-- Player 1
	if p1[3] then
	if p1[2] > height then p1[2] = height end
	if p1[2] < 0      then p1[2] = 0      end
	if p1[1] > width  then p1[1] = width  end
	if p1[1] < 0      then p1[1] = 0      end
	
	up    = key.isDown(keys['up'])
	down  = key.isDown(keys['down'])
	left  = key.isDown(keys['left'])
	right = key.isDown(keys['right'])
	shoot = key.isDown(keys['shoot'])
	
	ul = up and left
	ur = up and right
	dl = down and left
	dr = down and right

	    if ul    then angle[1] = 7
    elseif ur    then angle[1] = 9
    elseif dl    then angle[1] = 1
    elseif dr    then angle[1] = 3
    elseif left  then angle[1] = 4
    elseif right then angle[1] = 6
    elseif up    then angle[1] = 8
    elseif down  then angle[1] = 2
    end

	if up    then p1[2] = p1[2] - speed * dt end
	if down  then p1[2] = p1[2] + speed * dt end
	if left  then p1[1] = p1[1] - speed * dt end 
	if right then p1[1] = p1[1] + speed * dt end 

	if shoot then
		if not keylock['shoot'] then
			local lasermax = progress
			if lasermax > 9 then lasermax = 9 end
			if lens(lasers) < 2 + progress then
				table.insert(lasers, {p1[1], p1[2], angle[1], 0}) 
			end
			
			keylock['shoot'] = true
		end
	else keylock['shoot'] = false end
	end
	
	-- Player 2
	if p2[3] then
	if p2[2] > height then p2[2] = height end
	if p2[2] < 0      then p2[2] = 0      end
	if p2[1] > width  then p2[1] = width  end
	if p2[1] < 0      then p2[1] = 0      end
	
	up    = key.isDown(keys['up2'])
	down  = key.isDown(keys['down2'])
	left  = key.isDown(keys['left2'])
	right = key.isDown(keys['right2'])
	shoot = key.isDown(keys['shoot2'])
	
	ul = up and left
	ur = up and right
	dl = down and left
	dr = down and right

	    if ul    then angle[2] = 7
    elseif ur    then angle[2] = 9
    elseif dl    then angle[2] = 1
    elseif dr    then angle[2] = 3
    elseif left  then angle[2] = 4
    elseif right then angle[2] = 6
    elseif up    then angle[2] = 8
    elseif down  then angle[2] = 2
    end

	if up    then p2[2] = p2[2] - speed * dt end
	if down  then p2[2] = p2[2] + speed * dt end
	if left  then p2[1] = p2[1] - speed * dt end 
	if right then p2[1] = p2[1] + speed * dt end 

	if shoot then
		if not keylock['shoot2'] then
			local lasermax = progress
			if lasermax > 9 then lasermax = 9 end
			if lens(lasers) < 2 + progress then
				table.insert(lasers, {p2[1], p2[2], angle[2], 0}) 
			end
			
			keylock['shoot2'] = true
		end
	else keylock['shoot2'] = false end
	end
end

function love.draw()
	dt = love.timer.getDelta()
	
	addInfo('Info:')
	
	if settings then
		cursor = cursor or {0, 0} 
		addInfo('Select Button with '..upr(keys['up'] .. keys['left'] .. keys['down'] .. keys['right']))
		addInfo('Change Button with '..upr(keys['shoot']))
		return 0
	end
	
	addStats('Stats:')
	
	if menu then
		addInfo('Press F1 to open Settings')
		addInfo('Press F2 to change player amount')
		addInfo('Current Players: '..players)
		addInfo('')
		addInfo(fmt('Select Difficulty with %s and %s', upr(keys['left']), upr(keys['right'])) )
		addInfo("Start Game with "..upr(keys['shoot']) )
		
		local fh = font:getHeight() + 10
		pprint( title, width/2, height/2 + fh * -3)
		pprint("Difficulty", width/2, height/2 + fh*-1)
		pprint("Easy  Medium  Hard", width/2, height/2 + fh*0)
		pprint("^", width/2 - 92 + 46 * diff, height/2 + fh*1)
		--                   46*2       
		
		addStats("High Score: " .. hiscore[diff])
		--pprint("High Score: " .. hiscore[diff] , width/2, height/2 + fh*3)
		return 0
	end

	if dead then 
		local fh = font:getHeight() + 10
		pprint("You Died"              , width/2, height/2 - fh)
		pprint("Score: " .. score      , width/2, height/2)
		pprint("Press ENTER to Restart", width/2, height/2 + fh) 
		return 0 
	end
	
	addInfo('Player 1:')
	addInfo(fmt('Move with %s %s %s %s', upr(keys['up']), upr(keys['left']), upr(keys['down']), upr(keys['right'])) )
	addInfo('Shoot with ' .. upr(keys['shoot']) )
	
	if p1[3] then
		pprint('@',  p1[1], p1[2])
		pprint(LaserSprites[angle[1]], p1[1]+LaserAngle[angle[1]][1], p1[2]-LaserAngle[angle[1]][2])
	else
		pprint('X',  p1[1], p1[2])
	end
	
	if players >= 2 then
		addInfo('')
		addInfo('Player 2:')
		addInfo(fmt('Move with %s %s %s %s', keys['up2'], keys['left2'], keys['down2'], keys['right2']) )
		addInfo('Shoot with ' .. upr(keys['shoot2']) )
		
		
		if p2[3] then
			pprint('&',  p2[1], p2[2])
			pprint(LaserSprites[angle[2]], p2[1]+LaserAngle[angle[2]][1], p2[2]-LaserAngle[angle[2]][2])
		else
			pprint('Y',  p2[1], p2[2])
		end
		
		
	end
	
	if score > hiscore[diff] then hiscore[diff] = score end
	addStats("High Score: " .. hiscore[diff])
	addStats('Score: ' .. score)
	
	if distance(p1, p2) < 10 then
		p1[3] = true
		p2[3] = true
	end

	for k, v in pairs(lasers) do
		laserx, lasery, lasera, lasert = v[1], v[2], v[3], v[4]

		text = LaserSprites[lasera]
		loadstring(LaserMovement[lasera])()

		lasers[k][1] = laserx
		lasers[k][2] = lasery
		lasers[k][4] = lasers[k][4] + dt

		for k2, v2 in pairs(enemies) do
			local enemx, enemy = v2[1], v2[2]
			if distance({laserx, lasery}, {enemx, enemy}) < 10 then
				lasers[k] = nil
				enemies[k2] = nil
				score = score + 1
				progress = math.floor(score / 20)
				enemspeed = 10 * (0.5 * (diff)) + progress
				if enemspeed > 40 then enemspeed = 40 end
				while (lens(enemies) < ((score/1.5) + 20)) do
					SpawnEnemie()
				end
			end
		end

		local lasermax = 0.4 + (progress * 0.1)
		if lasermax > 5.6 then lasermax = 5 end

		if lasert > lasermax then 
			lasers[k] = nil
		else
			pprint(text, laserx, lasery)
		end
	end

	for k, v in pairs(enemies) do
		local x, y = v[1], v[2]
		local d  = distance({x, y}, p1)
		local d2 = distance({x, y}, p2)
		
		for k2, v2 in pairs(enemies) do
			if k ~= k2 then
				local x2, y2 = v2[1], v2[2]
				if distance({x, y}, {x2, y2}) < 5 then
					enemies[k2] = nil
					SpawnEnemie()
				end
			end
		end
		
		_ = function(z)
		local x, y = p1[3], p2[3]
		
			if x and y then
				return z
			else
				if x then return true 
				else 	  return false end
			end
			
		end
		
		
		
		if _(d < d2) then
		
			if x > p1[1] then x = x - enemspeed * dt
						else x = x + enemspeed * dt end

			if y > p1[2] then y = y - enemspeed * dt
						else y = y + enemspeed * dt end

		else

			if x > p2[1] then x = x - enemspeed * dt
						else x = x + enemspeed * dt end

			if y > p2[2] then y = y - enemspeed * dt
						else y = y + enemspeed * dt end

		end
		
		if enemies[k] then
			enemies[k][1] = x
			enemies[k][2] = y
		end

		if d  < 12 then p1[3] = false end
		if d2 < 12 then p2[3] = false end
		
		pprint('#', x, y)
	end

end

KeyPressedTablet = {
	['f1']  = function() settings = true end,
	['f2']  = function() if menu then players = players + 1 if players > 2 then players = 1 end end end,
	['f11'] = function() win.setFullscreen(not win.getFullscreen()) end
}
function love.keypressed(k)
	
	-- print('Pressed '..k)
	
	local f = KeyPressedTablet[k]
	if f then f() end
	
	
	if k == 'escape' then
		if     settings then settings = false
		elseif not menu then menu = true
		end
	end
	
	if menu then
		 if k == keys['left']  then diff = diff - 1 
	 elseif k == keys['right'] then diff = diff + 1 
	 elseif k == keys['shoot'] then 
	 		menu = false 
			dead = false
			love.load()
			enemspeed = 10 * (0.5 * (diff))
			keylock = {}
			keylock['shoot'] = true 
	 	end

		if diff < 1 then diff = 3
	 elseif diff > 3 then diff = 1
	 	end

	end

	if dead then
		if k == keys['restart'] then love.load() end
	end
end
