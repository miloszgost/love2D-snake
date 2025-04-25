--[[
20-24/04/2025
Milosz Gostynski
Simple 'Snake' Game using Lua (in Love2D)
--]]

move_time = 0.25   -- 0.5 second
time = 0

move_record = {}
gamestate = "continue"
score = 0

is_grid = false
-- is_grid = true


function love.load()
    -- display control
    width = 600
    height = 800
    love.window.setMode(width, height)
    love.window.setTitle("Milo's Snake Game :D")
    text = {
        score = {
            x = 100,
            y = 100,
            font = love.graphics.setNewFont(25) 
        },
        stats = {
            x = 100,
            y = 140,
            font = love.graphics.setNewFont(15)
        },
        gameover = {
            x = width/2,
            y = height/2,
            font = love.graphics.setNewFont("CharterBT-Bold.ttf", 40)
        },
        draw = function(self, gamestate)
            love.graphics.setColor(1,1,1)
            set_x = self.gameover.x - 40*5
            set_y = self.gameover.y - 40*5
            if gamestate == "gameover" then
                love.graphics.setColor(0.5, 0.5, 0.5)
                love.graphics.polygon("fill", set_x, set_y, set_x+400, set_y, set_x+400, set_y+200, set_x, set_y+200)
                love.graphics.setFont(self.gameover.font)
                love.graphics.setColor(1, 1, 1)
                love.graphics.print("GAME OVER\nPress 'r' to restart\nPress 'Esc' to exit", set_x, set_y, 0)
            end
            love.graphics.setFont(self.score.font)
            -- arguments for print(): text,                        x,y,angle,scale_x,scale_y
            love.graphics.print(string.format("Score: %d", score), self.score.x, self.score.y, 0)
                
            love.graphics.setFont(self.stats.font)
            delta   = love.timer.getAverageDelta()
            fps     = love.timer.getFPS()
            love.graphics.print(string.format("AvgDelta: %f\nFPS: %d", delta, fps), self.stats.x, self.stats.y, 0)

        end
    }

    snake = {
        x = width/2,
        y = height/2,
        radius = 25,
        draw = function(x, y, radius)
            -- draw head
            love.graphics.setColor(1, 0, 0)
            love.graphics.circle("fill", x, y, radius)
            love.graphics.setColor(0, 0, 0)
            love.graphics.circle("fill", x+5, y-5, 5)
            love.graphics.circle("fill", x-5, y-5, 5)
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("fill", x+5, y-5-1, 2)
            love.graphics.circle("fill", x-5, y-5-1, 2)
            -- draw the rest
            love.graphics.setColor(1, 0, 0)
            for i, bodypart in ipairs(move_record) do
                -- draw last moves 
                if #move_record-i < score then
                    love.graphics.circle("fill", bodypart[1], bodypart[2], snake.radius)
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.setFont(text.score.font)
                    love.graphics.print(#move_record-i+1, bodypart[1], bodypart[2])
                    love.graphics.setColor(1, 0, 0)
                end
            end
        end
    }
    -- line generation:
    cell_size = 2*snake.radius
    grid_lines = {}
    -- vertical lines
    for x = cell_size, width, cell_size do
        local line = {x, 0, x, height}
        table.insert(grid_lines, line)
    end
    -- horizontal lines
    for y = cell_size, height, cell_size do
        local line = {0, y, width, y}
        table.insert(grid_lines, line)
    end
    -- -------
    food = {
        x = 0,
        y = 0,
        radius = 25,
        draw = function(x, y, radius)
            love.graphics.setColor(1, 1, 0)
            love.graphics.circle("line", x, y, radius)
        end
    }
    function food:new_position()
        x = math.random(1, width/cell_size-1)*cell_size
        y = math.random(1, height/cell_size-1)*cell_size
        -- don't repeat current position
            
        if x == self.x and y == self.y then
            food:new_position()
        else
            self.x = x
            self.y = y
        end
    end
    -- generate position on start
    food:new_position()
    function food:is_eaten()
        if math.abs(self.x-snake.x) < self.radius+snake.radius and 
            math.abs(self.y-snake.y) < self.radius+snake.radius then
            return true
        end
        return false
    end
end

function love.draw()
    -- draw grid
    love.graphics.setColor(0.3, 0.6, 0.3)
    if is_grid then
       love.graphics.setLineWidth(2)
        for i, line in ipairs(grid_lines) do
            love.graphics.line(line)
        end 
    end
    
    snake.draw(snake.x, snake.y, snake.radius)
    food.draw(food.x, food.y, food.radius)
    text:draw(gamestate)
end

function love.update(dt)
    time = time + dt
    if gamestate=="gameover" then
        if love.keyboard.isDown('r') then
            move_record = {}
            time = 0; score = 0
            snake.x = width/2
            snake.y = height/2
            gamestate = "continue"
        elseif love.keyboard.isDown('escape') then
            love.event.quit()
        end
    elseif time > move_time then
        time = 0
        -- update snake:
        --  save previous move
        if love.keyboard.isDown('w', 's', 'a', 'd') then
            table.insert(move_record, {snake.x, snake.y})
        end
        --  update current move
        if love.keyboard.isDown('w') then
            snake.y = snake.y - cell_size
        elseif love.keyboard.isDown('s') then
            snake.y = snake.y + cell_size
        elseif love.keyboard.isDown('a') then
            snake.x = snake.x - cell_size
        elseif love.keyboard.isDown('d') then
            snake.x = snake.x + cell_size
        end
        -- ----------
        -- check body collision
        for i=1, score-1 do
            bodypart = move_record[#move_record-i]
            
            temp_x = bodypart[1]
            temp_y = bodypart[2]
            if (snake.x == temp_x and snake.y == temp_y) then
                gamestate = "gameover"
                break
            else
                gamestate = "normal"
            end
        end
        -- check window collision
        if (snake.x < 0 or snake.y < 0 or snake.x > width or snake.y > height) then
            gamestate = "gameover"
        end
        -- update score(length) and food 
        if food:is_eaten() then
            score = score + 1
            if #move_record > score then
                table.remove(move_record, 1)
            end
            food:new_position()
        end
    end
end

