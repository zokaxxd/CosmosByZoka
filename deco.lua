eyes = {}
local Rot
Rot = love.math.random() * (2 * math.pi) 

function spawnEyes(ex, ey)
    local eye = world:newRectangleCollider(ex, ey, 32, 32, {collision_class = 'eye'})
    eye:setType('static')
    eye.x = ex
    eye.y = ey
    table.insert(eyes, eye)
end

function destroyEyes()
    for i = #eyes, 1, -1 do
        if eyes[i] then eyes[i]:destroy() end
        table.remove(eyes, i)
    end
    eyes = {}
end

function detaUpdate(dt)
    animations.eyes:update(dt) 
end

function DrawEyes()
    for i, eye in ipairs(eyes) do
        animations.eyes:draw(sprites.eyes, eye.x, eye.y, Rot, 3, 3, 32, 32)
    end
end

tentacles = {}

function spawnTentacles(tX, tY)
    local tentacle = world:newRectangleCollider(tX, tY, 10, 10, {collision_class = 'tentacle'})
    tentacle:setType('static')
    tentacle.x = tX
    tentacle.y = tY
    table.insert(tentacles, tentacle)
end
function destroyTentacles()
    for i = #tentacles, 1, -1 do
        if tentacles[i] then tentacles[i]:destroy() end
        table.remove(tentacles, i)
    end
    tentacles = {}
end
function tentacleUpdate(dt)
    animations.tenta:update(dt)
end
function DrawTentacles()
    for i,t in ipairs(tentacles) do
        animations.tenta:draw(sprites.tenta, t.x, t.y, nil, 7, 7, 26, 30)
    end
end