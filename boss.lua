bosses = {}

bosseStats = {


}
function spawnBoss(bX, bY)
    local boss = world:newRectangleCollider(bX, bY, 90, 180, {collision_class = 'boss'})
    boss:setLinearDamping(10)   -- resistência ao movimento
    boss:setGravityScale(1)
    boss:setFixedRotation(true) -- não rotaciona
    boss.direction = 1
    boss.speed = 150
    boss.attack = false
    boss.active = false
    boss.atackTimer = 0
    boss.health = 300
    boss.animation = animations.boss  -- animação idle do boss
    boss.spriteAtual = sprites.bossIdle
    table.insert(bosses, boss)
end

function BossUpdate(dt)
    for i,b in ipairs(bosses) do
        b.animation:update(dt)
        local bx, by = b:getPosition()
        local px, py = player:getPosition()
        local dist = math.sqrt((bx - px)^2 + (by - py)^2)
        if dist < 1000 then
            b.active = true
        end
        if b.active then
            if px > bx then
                b.direction = 1
            else
                b.direction = -1
            end
            local _, vy = b:getLinearVelocity()
            b:setLinearVelocity(b.speed * b.direction, vy)
        end
        if b.active then
            
            if dist < 120 then
                if not b.attack then
                    b.attack = true
                    b.atackTimer = 0.5
                    b.animation = animations.bossAttack
                    b.spriteAtual = sprites.bossAttack
                    b.hitbox = world:newCircleCollider(bx + (50 * b.direction), by, 50, {collision_class = 'bossAttack'})
                    b.hitbox:setType('static')
                end
            end

            if b.attack then
                b.atackTimer = b.atackTimer - dt

                if b.hitbox then
                    b.hitbox:setPosition(bx + (60 * b.direction), by)
                end

                if b.hitbox then
                    b.hitbox:setPosition(bx + (60 * b.direction), by)
                    local hbx, hby = b.hitbox:getPosition()
                    local hit = world:queryCircleArea(hbx, hby, 60, {'player'})
                    if #hit > 0 then
                        if player.invencible <= 0 then
                            player.health = player.health - 20
                            sounds.Hurt:play()
                            sounds.Hurt:setVolume(0.5)
                            player.invencible = 2
                            player.flash = true
                            player.flashTimer = 2
                        end
                    end
                end

                if b.atackTimer <= 0 then
                    b.attack = false
                    b.animation = animations.boss
                    b.spriteAtual = sprites.bossIdle
                    if b.hitbox then
                        b.hitbox:destroy()
                        b.hitbox = nil
                    end
                end
            end
            
            --[[if dist < 100 then
                if player.invencible <= 0 then
                    player.health = player.health - 10
                    sounds.Hurt:play()
                    sounds.Hurt:setVolume(0.5)
                    player.invencible = 2
                    player.flash = true
                    player.flashTimer = 2
                end
            end]]--
        end
    end 
    for i,b in ipairs(bosses) do
        local bx, by = b:getPosition()
        local colliders = world:queryCircleArea(bx + (10 * b.direction), by + -60, 35, {'player'})
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
    if #bosses == 0 and hadBoss then
        bosses = {}
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
function BossDraw()
    for i,b in ipairs(bosses) do
        if b.active then
            local bx, by = b:getPosition()
            
            -- nome centralizado em cima
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("CEIFA CU ", bx - 200, by - 280, 400, 'center')
            
            -- barra de vida
            local maxHealth = 300
            local barWidth = 200
            local barHeight = 15
            local healthPercent = b.health / maxHealth
            
            -- fundo da barra (vermelho escuro)
            love.graphics.setColor(0.4, 0, 0)
            love.graphics.rectangle('fill', bx - barWidth/2, by - 250, barWidth, barHeight)
            
            -- vida atual (vermelho vivo)
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle('fill', bx - barWidth/2, by - 250, barWidth * healthPercent, barHeight)
            
            -- borda
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle('line', bx - barWidth/2, by - 250, barWidth, barHeight)
            
            love.graphics.setColor(1, 1, 1)
            b.animation:draw(b.spriteAtual, bx, by, nil, 4 * b.direction, 4, 40, 60)
        end
    end
end
function attackPlayer()
    for i,b in ipairs(bosses) do
        local bx, by = b.getPosition()
        local AtiveAttack = world:newCircleCollider(bx + (30 * b.direction), by + -10, 40, {collision_class = 'AtiveAttack'})
        if player:enterCollider(AtiveAttack) then
            bosseStats.attack = true
            bosseStats.active = true
            bosseStats.animationAttack = animations.bossAttack
            bosseStats.spriteAtual = sprites.bossAttack
        end
    end
end