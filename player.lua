playerX = 500
playerY = 100


function Respawn() -- respawna o player, e spawna tmb
    player = world:newRectangleCollider(playerX, playerY, 58, 98, {collision_class = 'player'}) -- player e seus assets 
    player:setFixedRotation(true)
    player.velo = 350
    player.health = 100
    player.dash = false
    player.invencible = 0
    player.isMoving = false
    player.grounded = true
    player.attack = false
    player.attackTimer = 0
    player.animation = animations.idle
    player.SpriteAtual = sprites.playerIdle
    player.direction = 1
    player.flash = false
    player.flashTimer = 0
end

function playerUpdate(dt)

    if player.body then -- se o jogador tiver vivo
        player.invencible = player.invencible - dt -- diminui a invencibilidade do player
    
        if player.attack then
            player.attackTimer = player.attackTimer - dt
            if player.attackTimer <= 0 then
                player.attack = false
            end
        end

        local colliders = world:queryRectangleArea(player:getX() - 29, player:getY() + 49, 60, 2, {'platform'}) --verifica se o player esta no chão
        if #colliders > 0 then
            player.grounded = true -- se tiver ele pode pular ou dashar dnv
        else
            player.grounded = false -- se nn nao pode
        end


        player.isMoving = false -- para saber se ele esta andando ou nn 
        local px, py = player:getPosition()
        if love.keyboard.isDown('d') then
            player:setX(px + player.velo * dt)
            player.isMoving = true 
            player.direction = 1 -- muda a direção do sprite
        end
        if love.keyboard.isDown('a') then
            player:setX(px - player.velo * dt)
            player.isMoving = true
            player.direction = -1 -- muda a direção do sprite
        end

        if player:enter('danger') then -- se tocar no "void" 
            player.health = player.health - 50 -- diminui a vida do player
            player:setPosition(playerX, playerY) -- volta ao inicio
        end
        if player:enter('active') and not bossTriggered then
            bossTriggered = true
            bossIntroPhase = 1
            bossIntroTimer = 0
            if bosses[1] then
                camScrollX, camScrollY = bosses[1]:getPosition()
            end
            spawnBlock(entranceX, entranceY, entranceW, entranceH)
        end
        --[[if active == true then
            cam:lookAt(px, love.graphics.getHeight()/2)
            
        end
        if bosses[1] then
            local bx, by = bosses[1]:getPosition()
            camScrollX = bx
            camScrollY = by
        end

        if active and saveData.currentLevel == "level3" then
            local bx, by = bosses[1]:getPosition()
            camScrollX = camScrollX - (bx - camScrollX) * 0.02
            camScrollY = camScrollY - (by - camScrollY) * 0.02
            cam:lookAt(camScrollX, camScrollY)
        else
            local px, py = player:getPosition()
            cam:lookAt(px, py)
        end ]]

        -- se ele estiver no chao nn chama a aninmation de jump, mas caso ele pular chama a animação de jump
        if player.grounded then -- se for verdadeiro ele esta no chão
            if player.attack then

            elseif player.isMoving then -- se ele estiver andando
                player.animation = animations.walking -- troca a animation
                player.SpriteAtual = sprites.playerWalk -- troca o sprite
            else
                player.animation = animations.idle -- se nn tiver andando nn troca, fica a aninmation de idle
                player.SpriteAtual = sprites.playerIdle -- sprite a msm coisa
            end
        else
            if not player.attack then
                player.animation = animations.jump -- chama a animação de jump
                player.SpriteAtual = sprites.playerJump -- chama a sprite de jump
            end
        end
        if player.flash then
            player.flashTimer = player.flashTimer - dt
            if player.flashTimer <= 0 then
                player.flash = false
            end
        end
    end

        player.animation:update(dt) -- atualiza a animation
end

function playerDraw()
    
    local px, py = player:getPosition()
    local shouldDraw = true
    if player.flash then
        shouldDraw = math.floor(player.flashTimer * 8) % 2 == 0
    end

    if shouldDraw then -- player pisca se tomar dano e o invencible tiver ativo
        player.animation:draw(player.SpriteAtual, px, py, nil, 3 * player.direction, 3, 26, 24.5)
    end
    love.graphics.setColor(1, 1, 1)

    -- barra de vida
    local maxHealth = 100
    local barWidth = 150
    local barHeight = 12
    local healthPercent = player.health / maxHealth

    -- fundo
    love.graphics.setColor(0.4, 0, 0)
    love.graphics.rectangle('fill', px - barWidth/2, py - 120, barWidth, barHeight)

    -- vida atual
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle('fill', px - barWidth/2, py - 120, barWidth * healthPercent, barHeight)

    -- borda
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle('line', px - barWidth/2, py - 120, barWidth, barHeight)

    love.graphics.setColor(1, 1, 1)
end