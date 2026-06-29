local ObjectContainer = {}

ObjectContainer.objects = {}
local objectQueue = {}
local nextZ = 0

local function rebuildQueue()
    for i = #objectQueue, 1, -1 do objectQueue[i] = nil end
    for _, obj in pairs(ObjectContainer.objects) do
        objectQueue[#objectQueue + 1] = obj
    end
    table.sort(objectQueue, function(a, b) return a.z < b.z end)
end

function ObjectContainer.newObject(name, z, cfg)
    local object = irisObject:new()

    -- defaults que o container precisa
    object.z = z ~= nil and z or nextZ
    object.scrollFactor = { x = 1, y = 1 }
    nextZ = nextZ + 1

    cfg(object)

    ObjectContainer.objects[name] = object
    rebuildQueue()
end

function ObjectContainer.getMemberNamed(name)
    return ObjectContainer.objects[name]
end

function ObjectContainer.draw(camera)
    for _, obj in ipairs(objectQueue) do
        local offsetX = camera.x * (1 - obj.scrollFactor.x)
        local offsetY = camera.y * (1 - obj.scrollFactor.y)

        love.graphics.push()
        love.graphics.translate(offsetX, offsetY)
        obj:draw()
        love.graphics.pop()
    end
end

function ObjectContainer.update(elapsed)
    for i = #objectQueue, 1, -1 do
        local obj = objectQueue[i]
        obj:update(elapsed)
        if obj._destroyed then
            ObjectContainer.objects[obj._name] = nil
            table.remove(objectQueue, i)
        end
    end
end

return ObjectContainer