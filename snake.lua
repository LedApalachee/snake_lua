--[[
		The "Snake" game written in Lua
		Fuat Chumarin (LedApalachee), the mid-summer of 2022
--]]


-- load settings
dofile("config.lua")


-- the snake
snake = {}
snake_len = 1
snake.dx = 0
snake.dy = 0


-- placing the snake on initial position
snake[1] = {x = map_sx // 2 + 1,
			y = map_sy // 2 + 1}


-- generating food after snake eats it
function gen_food ()
	food_x = math.random(1, map_sx)
	food_y = math.random(1, map_sy)
	for i = 1, snake_len do
		if snake[i].x == food_x and snake[i].y == food_y then
			return gen_food() -- proper tail call
		end
	end
end


-- check for snake drawing (fsd)
function check_fsd (x,y)
	for i = 1, snake_len do
		if snake[i].x == x and snake[i].y == y then
			return true
		end
	end
	return false
end


-- draw the entire picture
function draw ()
	for x = 1, map_sx+2 do
		io.write(wall_char)
	end
	io.write("\n")
	for y = 1, map_sy do
		io.write(wall_char)
		for x = 1, map_sx do
			if x == food_x and y == food_y then
				io.write(food_char)
			elseif check_fsd(x,y) then
				io.write(snake_char)
			else
				io.write(floor_char)
			end
		end
		io.write(wall_char .. "\n")
	end
	for x = 1, map_sx+2 do
		io.write(wall_char)
	end
	io.write("\nlength: " .. snake_len .. "\n")
end


function game_over (message)
	io.write(message)
	os.exit(0)
end


function snake_grow (where_x, where_y)
	local x, y
	if snake_len < 2 then
		x = snake[1].x - snake.dx
		y = snake[1].y - snake.dy
		snake_len = snake_len + 1
		snake[snake_len] = {x = x, y = y}
	else
		snake_len = snake_len + 1
		snake[snake_len] = {x = where_x, y = where_y}
	end
end


function cross_border ()
	local x, y = snake[1].x, snake[1].y
	if snake.dx == -1 then x = map_sx
	elseif snake.dx == 1 then x = 1 end
	if snake.dy == -1 then y = map_sy
	elseif snake.dy == 1 then y = 1 end
	-- checking for collision with itself
	for i = 1, snake_len do
		if x == snake[i].x and y == snake[i].y then
			game_over("The poor snake bited itself\n")
		end
	end
	for i = snake_len, 2, -1 do
		snake[i].x = snake[i-1].x
		snake[i].y = snake[i-1].y
	end
	snake[1] = {x = x, y = y}
end


function move_snake ()
	if snake.dx == 0 and snake.dy == 0 then
		return
	end
	local x = snake[1].x + snake.dx
	local y = snake[1].y + snake.dy

	-- checking for collision with itself
	for i = 1, snake_len do
		if x == snake[i].x and y == snake[i].y then
			game_over("The poor snake bited itself\n")
		end
	end

	-- checking for finding food
	if x == food_x and y == food_y then
		local where_x, where_y = snake[snake_len].x, snake[snake_len].y
		for i = snake_len, 2, -1 do
			snake[i].x = snake[i-1].x
			snake[i].y = snake[i-1].y
		end
		snake[1] = {x = food_x, y = food_y}
		snake_grow(where_x, where_y)
		gen_food()

	-- checking for crossing a border
	elseif x < 1 or x > map_sx or y < 1 or y > map_sx then
		if toric_map then
			cross_border()
		else
			game_over("Your head bumped into another brick in the wall\n")
		end

	-- nothing in the way
	else
		for i = snake_len, 2, -1 do
			snake[i].x = snake[i-1].x
			snake[i].y = snake[i-1].y
		end
		snake[1] = {x = x, y = y}
	end
end


function input ()
	local key = io.read(1)
	while key == '\n' do key = io.read(1) end

	local sdx, sdy = snake.dx, snake.dy

	if key == key_move_up then
		snake.dx, snake.dy =  0, -1
	elseif key == key_move_down then
		snake.dx, snake.dy =  0,  1
	elseif key == key_move_left then
		snake.dx, snake.dy = -1,  0
	elseif key == key_move_right then
		snake.dx, snake.dy =  1,  0
	elseif key == key_quit then
		game_over("Good bye ;)\n")
	end

	if (snake_len > 1 and snake[1].x + snake.dx == snake[2].x and snake[1].y + snake.dy == snake[2].y) then
		snake.dx, snake.dy = sdx, sdy
	end
end


os.execute(clear_cmd)
gen_food()

-- the main loop
while true do
	os.execute(clear_cmd)
	draw()
	input()
	move_snake()
end
