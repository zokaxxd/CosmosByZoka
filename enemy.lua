enemies = {}

function spawnEnemys(x, y)
    local enemy = world:newRectangleCollider(x, y, 50, 70, {collision_class = 'enemy'})
    enemy.direction = 1
    enemy.speed = 200
    enemy.health = 30
    enemy.animation = animations.enemy
    table.insert(enemies, enemy)
end

function enemyUpdate(dt)
    
    for i,e in ipairs(enemies) do
        e.animation:update(dt)
        local ex, ey = e:getPosition()
        local colliders = world:queryRectangleArea(ex + (30 * e.direction), ey + 45, 5, 5, {'platform'})
            if #colliders > 0 then
                e.direction = e.direction * -1
            end

        e:setX(ex + e.speed * dt * e.direction)
    end
    for i, e in ipairs(enemies) do
        local ex, ey = e:getPosition()
        local colliders = world:queryCircleArea(ex + (10 * e.direction), ey + -10, 25, {'player'})
            if #colliders > 0 then
                if player.invencible <= 0 then
                    player.health = player.health - 10
                    sounds.Hurt:play()
                    sounds.Hurt:setVolume(0.5)
                    player.invencible = 2
                    player.flash = true
                    player.flashTimer = 2
                end
            end
    end
    if #enemies == 0 and hadEnemy then
        local bl = #blocks
        while bl > -1 do
            if blocks[bl] ~= nil then
                blocks[bl]:destroy()
            end
            table.remove(blocks, bl)
            bl = bl - 1
        end
        blocks = {}
    end
end

function enemyDraw()
    for i,e in ipairs(enemies) do
        local ex, ey = e:getPosition()
        
        -- barra de vida
        local maxHealth = 30
        local barWidth = 80
        local barHeight = 8
        local healthPercent = e.health / maxHealth

        love.graphics.setColor(0.4, 0, 0)
        love.graphics.rectangle('fill', ex - barWidth/2, ey - 100, barWidth, barHeight)

        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle('fill', ex - barWidth/2, ey - 100, barWidth * healthPercent, barHeight)

        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle('line', ex - barWidth/2, ey - 100, barWidth, barHeight)

        love.graphics.setColor(1, 1, 1)
        e.animation:draw(sprites.enemy, ex, ey, nil, 3 * e.direction, 3, 26, 30)
    end
end