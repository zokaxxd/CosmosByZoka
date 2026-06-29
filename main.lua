function love.load ()
    --[[
    col = require 'others/collision'
    obj = require 'others/Object'
    ]]

    love.window.setMode(1280, 768) -- muda o tamanho do jogo
    sti = require 'libraries/Simple-Tiled-Implementation/sti' -- importar o tiled
    anim8 = require 'libraries/anim8/anim8' -- para as animações
    wf = require 'libraries/windfield/windfield' --fisicas do game
    cameraFile = require 'others/message' --chama a camera

    cam = cameraFile() 
    world = wf.newWorld(0, 800, false) -- cria o world
    world:setQueryDebugDrawing(true)
    love.graphics.setFont(love.graphics.newFont(30)) -- aumenta as fontes
    love.graphics.setDefaultFilter("nearest", "nearest") -- melhoras as sprites
    

    States = { --estados do game, pode ser menu, game, dead, pause, credits
        menu = "menu",
        game ="game",
        dead = "dead",
        pause ="pause",
        credit = "credits"
    }
    stateAtual = States.menu -- jogo começa no menu

    sprites = { -- imagens dos sprites
        back = love.graphics.newImage('sprites/backgro/menu.png'),
        playerIdle = love.graphics.newImage('sprites/player/HostileIdleReaper-Sheet.png'),
        playerWalk = love.graphics.newImage('sprites/player/HostileRunningReaper-Sheet.png'),
        playerAttack = love.graphics.newImage('sprites/player/HostileAttackReaper-Sheet.png'),
        playerJump = love.graphics.newImage('sprites/player/HostileJumpReaper.png'),
        backGma = love.graphics.newImage('sprites/backgro/bg_001.png'),
        enemy = love.graphics.newImage('sprites/enemys/bat-NESW.png'),
        tenta = love.graphics.newImage('sprites/deta/tentacles.png'),
        eyes = love.graphics.newImage('sprites/deta/eyes.png'),
        bossIdle = love.graphics.newImage('sprites/Boss/idle.png'),
        bossAttack = love.graphics.newImage('sprites/Boss/attacking.png'),
        bossSkill = love.graphics.newImage('sprites/Boss/skill1.png'),
        star = love.graphics.newImage('sprites/star_shape.png')
    }

    --=============== Grid para as animations
    local grid = anim8.newGrid(48, 48, sprites.playerIdle:getWidth(), sprites.playerIdle:getHeight())
    local grid2 = anim8.newGrid(48, 48, sprites.playerWalk:getWidth(), sprites.playerWalk:getHeight())
    local grid3 = anim8.newGrid(48, 48, sprites.playerAttack:getWidth(), sprites.playerAttack:getHeight())
    local grid4 = anim8.newGrid(48, 48, sprites.playerJump:getWidth(), sprites.playerJump:getHeight())
    local gridEnemy = anim8.newGrid(48, 64, sprites.enemy:getWidth(), sprites.enemy:getHeight())
    local grid5 = anim8.newGrid(48, 48, sprites.tenta:getWidth(), sprites.tenta:getHeight())
    local grid6 = anim8.newGrid(32, 32, sprites.eyes:getWidth(), sprites.eyes:getHeight())
    local gridBoss = anim8.newGrid(100, 100, sprites.bossIdle:getWidth(), sprites.bossIdle:getHeight())
    local gridBossAttack = anim8.newGrid(100, 100, sprites.bossAttack:getWidth(), sprites.bossAttack:getHeight())
    local gridBossSkill = anim8.newGrid(100, 100, sprites.bossSkill:getWidth(), sprites.bossSkill:getHeight())

    
    animations = { -- animations em si 
        idle = anim8.newAnimation(grid('1-5', 1), 0.10),
        walking = anim8.newAnimation(grid2('1-8', 1), 0.10),
        attack = anim8.newAnimation(grid3('1-10', 1), 0.06),
        jump = anim8.newAnimation(grid4('1-6', 1), 0.47),
        enemy = anim8.newAnimation(gridEnemy('1-3', 2), 0.37),
        tenta = anim8.newAnimation(grid5('1-6', 1), 0.1),
        eyes = anim8.newAnimation(grid6('1-28', 1), 0.1),
        boss = anim8.newAnimation(gridBoss('1-4', 1), 0.37),
        bossAttack = anim8.newAnimation(gridBossAttack('1-6', 1), 0.08),
        bossSkill = anim8.newAnimation(gridBossSkill('1-6', 1), 0.37)
    }

    sounds = {} --Sons do game
    sounds.msc = love.audio.newSource('sounds/backMusics/2 Fredelig Sinn Loop 3.wav', 'stream')
    sounds.mscBoss = love.audio.newSource('sounds/backMusics/2 The Veil of Night Loop 3.wav', 'stream')
    sounds.jump = love.audio.newSource('sounds/Jump2.wav', 'static')
    sounds.enemyHurt = love.audio.newSource('sounds/Hit_Hurt10.wav', 'static')
    sounds.Hurt = love.audio.newSource('sounds/Hit_Hurt6.wav', 'static')
    sounds.foice = love.audio.newSource('sounds/freesound_community-sword-sound-2-36274.mp3', 'static')
    sounds.msc:setLooping(true)
    sounds.msc:setVolume(0.3) --volume

    sounds.msc:play() -- dar play na msc

    require 'enemy' -- chama o enemy.lua
    require 'player' -- chama o player.lua
    require 'libraries/show' 
    require 'deco' --decorações
    require 'boss' -- Boss
    
    world:addCollisionClass('platform') -- plataforma de teste
    world:addCollisionClass('enemy')
    world:addCollisionClass('danger') -- "void"
    world:addCollisionClass('eye')
    world:addCollisionClass('active')
    world:addCollisionClass('tentacle')
    world:addCollisionClass('AtiveAttack')
    world:addCollisionClass('Boss')
    --world:addCollisionClass('safe') -- 
    world:addCollisionClass('block') -- para o player nn sair correndo e zerar
    world:addCollisionClass('player', {ignores = {'eye', 'active', 'Boss'}}) --[[, ignores = {'platform'}]]
    world:addCollisionClass('bossAttack', {ignores = {'platform', 'enemy', 'eye', 'Boss', 'player'}}) -- bosta com bug e nn ignora o boss 

    Respawn() -- chama o respawn do player no player.lua
    player.animation = animations.idle -- o player começa com a animação de idle
    player.dash = false -- dash do player
    timeDash = 0 -- tempo para o dash
    
    platforms = {} -- para as plataformas pro player andar
    actives = {} -- actives para tais coisas(quando entrar no boss)
    hadBoss = false -- para saber se tem o boss
    hadEnemy = false -- para saber se tem o enemy
    

    
    dangerZone = world:newRectangleCollider(-500, 1300, 5000, 50, {collision_class = 'danger'}) -- "void"
    dangerZone:setType('static') -- fixa a "void"
    

    camScrollX = 0  -- para o scroll
    camScrollY = 0 -- para o scroll
    active = false
    bossIntroTimer = 0 -- timer pra intro
    bossIntroPhase = 0 -- intro quando o active for true
    endX = 0
    endY = 0
    blocks = {}
    fps = false
    
    save = require 'others/lirium' -- para salvar o game
    gameSave = save.new("cosmos")
    gameSave.save = { -- guardar oq quero salvar pra nn dar b.o
        currentLevel = "level1",
        score = 0
    }
    gameSave:initialize()
    saveData = gameSave.save
    score = saveData.score
    loadMap(saveData.currentLevel) -- carrega o mapa
    
    
end


function love.update (dt)

    timeDash = math.max(0, timeDash - dt)  -- coundown do dash
    

    if stateAtual ~= States.menu then 
        world:update(dt)  
    end
    
    if stateAtual == States.game then -- se o game estiver rodando
        if player.body then
            playerUpdate(dt) -- chama o playerUpodate do player.lua, onde tem os assets do player
            enemyUpdate(dt) -- chama o enemyUpdate do enemy.lua
            BossUpdate(dt) -- chama o BossUpdate do Boss.lua
            detaUpdate(dt) -- chama o detaUpdate do deco.lua
            tentacleUpdate(dt) -- chama o tentacleUpdate do deco.lua

            gameMap:update(dt) -- atualiza o mapa
            local px, py = player:getPosition() -- pega a posição do player
            if bossIntroPhase == 0 then -- se for 0 a camera vai olhar o X e Y do player
                cam:lookAt(px, py)

            elseif bossIntroPhase == 1 then -- do 1 ao 4 a camera vai olhar para o boss, dps parar e voltar para o player
                if bosses[1] then
                    local bx, by = bosses[1]:getPosition()
                    camScrollX = camScrollX + (bx - camScrollX) * 0.05
                    camScrollY = camScrollY + (by - camScrollY) * 0.05
                    cam:lookAt(camScrollX, camScrollY)
                end
                bossIntroTimer = bossIntroTimer + dt
                if bossIntroTimer > 2 then
                    bossIntroPhase = 2
                    bossIntroTimer = 0
                end

            elseif bossIntroPhase == 2 then 
                bossIntroTimer = bossIntroTimer + dt
                if bossIntroTimer > 1 then
                    bossIntroPhase = 3
                    bossIntroTimer = 0
                end

            elseif bossIntroPhase == 3 then
                camScrollX = camScrollX + (px - camScrollX) * 0.05
                camScrollY = camScrollY + (py - camScrollY) * 0.05
                cam:lookAt(camScrollX, camScrollY)
                bossIntroTimer = bossIntroTimer + dt
                if bossIntroTimer > 2 then
                    bossIntroPhase = 4
                    bossIntroTimer = 0
                    for i, b in ipairs(bosses) do
                        b.active = true
                    end
                end
            elseif bossIntroPhase == 4 then
                cam:lookAt(centerX, centerY) -- depois vai centralizar na sala do boss 
            end
            
        end

        local colliders = world:queryCircleArea(endX, endY, 10, {'player'}) -- para avançar de level
        if #colliders > 0 then
            if saveData.currentLevel == "level1" then -- Trocar o level
                loadMap("level2")
            elseif saveData.currentLevel == "level2" then
                loadMap("level3")
            elseif saveData.currentLevel == "level3" then
                if #bosses == 0 then
                    stateAtual = States.credit
                end
            end
        end
        if player.health <= 0 then -- se o player morreu
            player.body:destroy()
            stateAtual = States.dead -- muda o estado para dead
        end
        if saveData.currentLevel == "level3" then -- se o player chegar no level3 vai mudar a msc
            sounds.msc:stop()
            sounds.mscBoss:play()
            sounds.mscBoss:setVolume(0.3)
        else -- se nn vai ficar normal
            sounds.msc:play()
            sounds.mscBoss:stop()
        end
    end
end


function love.draw ()
    

    if stateAtual == States.menu then -- Menu do game 
        local w, h = love.graphics.getDimensions()
        local x, y = w / sprites.back:getWidth(), h / sprites.back:getHeight()
        love.graphics.draw(sprites.back, nil, nil, nil, x, y)
        love.graphics.setFont(love.graphics.newFont(67))
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("Cosmos", 200, 400, 800)
        love.graphics.setFont(love.graphics.newFont(30))
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Click anywhere for Start", 160, 550, 800)
    end

    if stateAtual == States.game then -- Game
        
        local w, h = love.graphics.getDimensions()
        local x, y = w / sprites.back:getWidth(), h / sprites.back:getHeight()
        love.graphics.draw(sprites.backGma, nil, nil, nil, x, y)
        
        cam:attach() -- tudo q tiver aki dentro ate "cam:detach()" vai pra camera
        gameMap:drawLayer(gameMap.layers["back"]) -- background do tiled
        gameMap:drawLayer(gameMap.layers["detais"]) -- detas do tiled
        gameMap:drawLayer(gameMap.layers["tile layer 1"]) -- chama o tileMap
        if fps then
            world:draw() -- desenha o world
        end
            playerDraw() -- chama o playerDraw do player.lua
            BossDraw() -- chama o BossDraw do Boss.lua
            enemyDraw() -- chama o enemyDraw do enemy.lua
            DrawEyes()  -- chama o DrawEyes do deco.lua
            DrawTentacles() -- chama o DrawTentacles do deco.lua
            love.graphics.printf("pule na estrela", endX - 400, endY - 200, 800, 'center') -- indicação
            love.graphics.draw(sprites.star, endX, endY, nil, 2, 2) -- estrela para avançar de level
        cam:detach() -- ate aki
        if fps then
                love.graphics.setColor(1, 1, 0)
                love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 70) -- mostra o fps
                love.graphics.setColor(1, 1, 1)
        end
        love.graphics.print("score " .. saveData.score, 10) -- score
    end
    
    if stateAtual == States.dead then -- Game over
        local w, h = love.graphics.getDimensions()
        local x, y = w / sprites.back:getWidth(), h / sprites.back:getHeight()
        love.graphics.setFont(love.graphics.newFont(70))
        love.graphics.draw(sprites.back, nil, nil, nil, x, y)
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("You died", 0, 280, 800, 'center')
        love.graphics.setFont(love.graphics.newFont(30))
    end

    if stateAtual == States.pause then -- pause
        local w, h = love.graphics.getDimensions()
        local x, y = w / sprites.back:getWidth(), h / sprites.back:getHeight()
        love.graphics.draw(sprites.back, nil, nil, nil, x, y)
        love.graphics.setFont(love.graphics.newFont(45))
        love.graphics.printf("paused", 472, 400, 800 )
        love.graphics.printf("Click anywhere to continue", 160, 550, 800, 'center')
        love.graphics.setFont(love.graphics.newFont(30))
    end
    if stateAtual == States.credit then -- final screen
        local w, h = love.graphics.getDimensions()
        local x, y = w / sprites.back:getWidth(), h / sprites.back:getHeight()
        love.graphics.draw(sprites.back, nil, nil, nil, x, y)
        love.graphics.setFont(love.graphics.newFont(45))
        love.graphics.printf("Thanks for playing!", 472, 400, 800 )
        love.graphics.printf("by zoka <3", 160, 550, 800, 'center')
        love.graphics.setFont(love.graphics.newFont(30))
    end

end

function love.keypressed(key)
    if stateAtual == States.game then
        if key == 'space' then -- para pular
            if player.grounded then -- se o player estiver no chão
                player:applyLinearImpulse(0, -7000) -- Pulo
                sounds.jump:play()
                sounds.jump:setVolume(0.5)
            end
        end
        
        if key == 'lshift' then -- dar o "tp" do player
            if timeDash <= 0 then 
                player.dash = true -- se der o tempo ele pode dashar dnv
                local px, py = player:getPosition()
                local colliders = world:queryRectangleArea(player:getX() - 40, player:getY() + 49, 80, 2, {'platform'})
                if #colliders > 0 then
                    --player:applyLinearImpulse(1000, 0)
                    if player.direction == 1 then
                        player:setX(px + 120) --pega a direction e aplica a impulso
                    elseif player.direction == -1 then
                        player:setX(px - 120) --pega a direction e aplica a impulso
                    end
                end
                timeDash = 1 -- redefine o tempo do dash
                
            end
        end
        if key == 'e' then -- para atacar
            player.attack = true
            player.attackTimer = 0.5
            player.animation = animations.attack -- troca a animation
            player.SpriteAtual = sprites.playerAttack -- troca o sprite
            sounds.foice:play()
            sounds.foice:setVolume(0.5)

            animations.attack.onloop = function ()
                player.attack = false
                animations.attack.onLoop = nil
            end

            local colliders = world:queryCircleArea(player:getX() + (60 * player.direction), player:getY(), 50, {'enemy'}) -- verifica se o inimigo ta no collision
            for i, col in ipairs(colliders) do
                for j, e in ipairs(enemies) do
                    if e == col then -- se o enemy estiver ele toma dano e a animação roda
                        local ex, ey = e:getPosition()
                        e.health = e.health - 15
                        if e.health <= 0 then
                            e:destroy()
                            table.remove(enemies, j)
                            sounds.enemyHurt:play()
                            sounds.enemyHurt:setVolume(0.5)
                            score = score + 1
                            saveData.score = score -- salva o score
                            gameSave:saveSlot() -- salva
                            
                        end
                    end
                end
            end
            local colliderss = world:queryCircleArea(player:getX() + (60 * player.direction), player:getY(), 50, {'boss'}) -- verifica se o boss ta no collision
            for i, col in ipairs(colliderss) do
                for j, b in ipairs(bosses) do
                    if b == col then -- se o boss estiver ele toma dano e a animação roda
                        b.health = b.health - 20
                            if b.health <= 0 then
                                b:destroy()
                                table.remove(bosses, j)
                                sounds.enemyHurt:play()
                                sounds.enemyHurt:setVolume(0.5)
                                score = score + 100
                                bossIntroPhase = 0 
                                saveData.score = score
                                gameSave:saveSlot() -- salva
                            end
                    end
                end
            end
        
        end

        if key == 'escape' and stateAtual == States.game then
            stateAtual = States.pause -- pausa o game 
        end
        if key == 'f5' then -- liga e desliga o fps e o world:draw()
            fps = not fps  -- liga e desliga
        end
    end
end

function love.mousepressed(x, y, button)

    if stateAtual == States.menu then
        if button == 1 then
            stateAtual = States.game -- do menuo para o game
        end
    end

    if stateAtual == States.pause then
        if button == 1 then 
            stateAtual = States.game -- do pause para o game
        end
    end

    if stateAtual == States.dead then
        if button == 1 then
            stateAtual = States.menu -- da morte para o menu
            bossTriggered = false
            bossIntroPhase = 0
            bossIntroTimer = 0
            Respawn()
            loadMap("level1")
        end
    end
end

function spawnPlatforms(x, y, width, height) -- spawna as plataformas pro player andar

    if width > 0 and height > 0 then
        local platform = world:newRectangleCollider(x, y, width, height, {collision_class = 'platform'})
        platform:setType('static')
        table.insert(platforms, platform)
    end
end

function destroyAll() -- destroi tudo
    local i = #platforms
    while i > -1 do
        if platforms[i] ~= nil then
            platforms[i]:destroy()
        end
        table.remove(platforms, i)
        i = i - 1
    end
    local e = #enemies
    while e > -1 do
        if enemies[e] ~= nil then
            enemies[e]:destroy()
        end
        table.remove(enemies, e)
        e = e - 1
    end
    local b = #bosses
    while b > -1 do
        if bosses[b] ~= nil then
            if bosses[b].hitbox then
                bosses[b].hitbox:destroy()
            end
            bosses[b]:destroy()
        end
        table.remove(bosses, b)
        b = b - 1
    end
    bosses = {}
    
    local a = #actives
    while a > -1 do
        if actives[a] ~= nil then
            actives[a]:destroy()
        end
        table.remove(actives, a)
        a = a - 1
    end
    actives = {}

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

function spawnActive(x, y) -- spawna o active
    local active = world:newRectangleCollider(x, y, 50, 200, {collision_class = 'active'})
    active:setType('static')
    table.insert(actives, active)
    
end

function spawnBlock(x, y, width, height) -- spawna o block e o entrance
    local block = world:newRectangleCollider(x, y, width, height, {collision_class = 'block'})
    block:setType('static')
    table.insert(blocks, block)
end

function loadMap(mapName) -- carrega os mapas
    saveData.currentLevel = mapName
    gameSave:saveSlot() -- salva o mapa q estiver
    hadBoss = false   
    hadEnemy = false  
    bossTriggered = false  
    destroyAll()
    destroyEyes()
    destroyTentacles()
    gameMap = sti("maps/" .. mapName .. ".lua")
    for i, obj in pairs(gameMap.layers["start"].objects) do -- pega o X e Y no tiled e coloca no game pro player nascer
        playerX = obj.x
        playerY = obj.y
    end
    player:setPosition(playerX, playerY)
    for i, obj in pairs(gameMap.layers["Platforms"].objects) do -- spawna as plataformas pro player andar pegando o X e Y no tiled
        spawnPlatforms(obj.x, obj.y, obj.width, obj.height)
    end
    for i, obj in pairs(gameMap.layers["enemies"].objects) do -- spawna os enemys pegando o X e Y no tiled
        spawnEnemys(obj.x, obj.y)
        hadEnemy = true
    end
    for i, obj in pairs(gameMap.layers["end"].objects) do -- pega o X e Y no tiled e coloca no game pro player ir pros outros levels
        endX = obj.x
        endY = obj.y
    end
    if gameMap.layers["eyes"] then -- spawna os eyes pegando o X e Y no tiled
        for i, obj in pairs(gameMap.layers["eyes"].objects) do  
            spawnEyes(obj.x, obj.y)
        end
    end
    if gameMap.layers["tentacle"] then -- spawna os tentacles pegando o X e Y no tiled
        for i, obj in pairs(gameMap.layers["tentacle"].objects) do   
            spawnTentacles(obj.x, obj.y)
        end
    end
    if gameMap.layers["Boss"] then -- spawna o boss pegando o X e Y no tiled
        for i, obj in pairs(gameMap.layers["Boss"].objects) do  
            spawnBoss(obj.x, obj.y)
            hadBoss = true
        end
    end
    if gameMap.layers["active"] then -- spawna o active pegando o X e Y no tiled
        for i, obj in pairs(gameMap.layers["active"].objects) do  
            spawnActive(obj.x, obj.y)
        end
    end
    if gameMap.layers["center"] then -- pega no tiled o X Y do centro da sala do boss e coloca pra camera focar no centro
        for i, obj in pairs(gameMap.layers["center"].objects) do  
            centerX = obj.x
            centerY = obj.y
        end
    end
    if gameMap.layers["block"] then -- spawna o block e o entrance pegando o X e Y no tiled
        for i, obj in pairs(gameMap.layers["block"].objects) do  
            spawnBlock(obj.x, obj.y, obj.width, obj.height)
        end
    end
    if gameMap.layers["entrance"] then -- pega no tiled o X e Y do entrance e spawna ele
        for i, obj in pairs(gameMap.layers["entrance"].objects) do  
            entranceX = obj.x
            entranceY = obj.y
            entranceW = obj.width
            entranceH = obj.height
        end
    end
end