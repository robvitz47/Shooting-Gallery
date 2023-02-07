local scores = {}
local serpent = require('src.serpent')

function love.load()
    target = {}
    target.x = 300
    target.y = 300
    target.radius = 50

    score = 0
    timer = 20
    gameState = 1
    speed = 200
    target.dx = 100
    target.dy = 100

    gameFont = love.graphics.newFont(40)

    sprites = {}
    sprites.sky = love.graphics.newImage('sprites/sky.png')
    sprites.target = love.graphics.newImage('sprites/target.png')
    sprites.crosshairs = love.graphics.newImage('sprites/crosshairs.png')

    love.mouse.setVisible(false)
    
    -- Load the high score table from a file, if it exists

    if love.filesystem.getInfo('src/scores.lua') then
        local data = love.filesystem.load('src/scores.lua')
        scores = data()
      end
      
      for i, score in ipairs(scores) do
        print(string.format("%2d. %5d", i, score))
      end
    end
function love.update(dt)
    if gameState == 2 then
        -- ...
        local randomNumberX = math.random(-1, 1) -- generates a random number between -1 and 1 for x-coordinate
        local randomNumberY = math.random(-1, 1) -- generates a random number between -1 and 1 for y-coordinate
        target.x = target.x + randomNumberX * dt * speed -- change target x-coordinate with random movement
        target.y = target.y + randomNumberY * dt * speed -- change target y-coordinate with random movement
        target.x = target.x + target.dx * dt
        target.y = target.y + target.dy * dt
        if target.x < target.radius or target.x > love.graphics.getWidth() - target.radius then
            target.dx = -target.dx
        end
        if target.y < target.radius or target.y > love.graphics.getHeight() - target.radius then
            target.dy = -target.dy
        end        
        if target.y < target.radius or target.y > love.graphics.getHeight() - target.radius then
            target.dy = -target.dy -- reverse direction when target hits the wall
    end
    timer = timer - dt
end
    if timer <= 0 then
        -- Save the current score to the high score table
        table.insert(scores, score)
        table.sort(scores, function(a, b) return a > b end)
        love.filesystem.write('src/scores.lua', "return " .. serpent.dump(scores))
        
        gameState = 1 -- change game state to end game when timer reaches 0
    end
function love.draw()
    love.graphics.draw(sprites.sky, 0, 0)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(gameFont)
    love.graphics.print("Score: " .. score, 5, 5)
    love.graphics.print("Time: " .. math.ceil(timer), 620, 5)
    
    if gameState == 1 then
        love.graphics.setColor(1, 1, 1, 1) --set setColor
        love.graphics.printf("Shooting Jam", 0, 100, love.graphics.getWidth(), "center")
        love.graphics.printf("Click to begin!", 0, 250, love.graphics.getWidth(), "center")
        love.graphics.printf("High Score:", 0, 425, love.graphics.getWidth(), "center")
        local y = 550
        for i, v in ipairs(scores) do
            love.graphics.print(v, love.graphics.getWidth() / 2, 500)
            y = y + 50
        end
    end

    if gameState == 2 then
        love.graphics.draw(sprites.target, target.x - target.radius, target.y - target.radius)
    end
    love.graphics.draw(sprites.crosshairs, love.mouse.getX() - 20, love.mouse.getY() - 20)
end
target.x = target.x + target.dx * dt
target.y = target.y + target.dy * dt
if target.x < target.radius or target.x > love.graphics.getWidth() - target.radius then
    target.dx = -target.dx -- reverse direction when target hits the wall
end
if target.y < target.radius or target.y > love.graphics.getHeight() - target.radius then
    target.dy = -target.dy -- reverse direction when target hits the wall
end
end
    
function love.mousepressed(x, y, button, istouch, presses)
    if gameState == 2 then
        local mouseToTarget = distanceBetween(x, y, target.x, target.y)
        if mouseToTarget < target.radius then
            if button == 1 then
                score = score + 1
                playHitEffect()
                target.x = math.random(target.radius, love.graphics.getWidth() - target.radius)
                target.y = math.random(target.radius, love.graphics.getHeight() - target.radius)
            elseif button == 2 then
                score = score + 2
                timer = timer - 1
                playBonusEffect()
                target.x = math.random(target.radius, love.graphics.getWidth() - target.radius)
                target.y = math.random(target.radius, love.graphics.getHeight() - target.radius)
            end
        end
    elseif button == 1 and gameState == 1 then
        gameState = 2
        timer = 20
        score = 0
    end
end

function playHitEffect()
    local hitSound = love.audio.newSource("sprites/explosion_09.wav", "static")
    love.audio.play(hitSound)
end

function playBonusEffect()
    local bonusHit = love.audio.newSource("sprites/explosion_13.wav", "static")
    love.audio.play(bonusHit)
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end
function serialize(t)
    local s = {}
    for k, v in pairs(t) do
        s[#s + 1] = k .. "=" .. v
    end
    return table.concat(s, "\n")
end
function love.quit()
    love.filesystem.write('scores.lua', 'return ' .. serialize(scores))
end