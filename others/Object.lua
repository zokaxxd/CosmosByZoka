---@class Object
---@field x number
---@field y number
---@field angle number
---@field scaleX number
---@field scaleY number
---@field alpha number
---@field flipX boolean
---@field flipY boolean
---@field visible boolean
---@field active boolean
---@field hitbox table
---@field _frameWidth number
---@field _frameHeight number
---@field _frames table
---@field _animations table
---@field _currentAnim table|nil
---@field _currentFrame number
---@field _timer number
---@field _mode string "spritesheet"|"frames"|"static"
local Object = class:extend("Object")

---Create a new Object instance
---@return Object
function Object:__construct()
    -- transform --
    self.x              = 0
    self.y              = 0
    self.z              = 0
    self.angle          = 0
    self.scaleX         = 1
    self.scaleY         = 1
    self.alpha          = 1
    self.flipX          = false
    self.flipY          = false
    self.scrollFactor   = {}
    self.scrollFactor.x = 1
    self.scrollFactor.y = 1

    -- state --
    self.visible        = true
    self.active         = true

    -- draw mode --
    self.drawMode       = "alpha"

    self._destroyed     = false

    -- graphic --
    self._image         = nil
    self._frames        = {}
    self._mode          = "static"
    self._frameWidth    = 0
    self._frameHeight   = 0

    -- animation --
    self._animations    = {}
    self._currentAnim   = nil
    self._currentFrame  = 1
    self._timer         = 0
    self._finished      = false

    -- hitbox (relative to x, y) --
    self.hitbox         = { x = 0, y = 0, w = 0, h = 0 }
end

--------------------------------------------------------------------------------
-- Graphics
--------------------------------------------------------------------------------

---Load a spritesheet and slice into quads
---@param image love.Image
---@param frameWidth number
---@param frameHeight number
function Object:setGraphic(image, frameWidth, frameHeight)
    self._image       = image
    self._mode        = "spritesheet"
    self._frameWidth  = frameWidth
    self._frameHeight = frameHeight
    self._frames      = {}

    local imgW        = image:getWidth()
    local imgH        = image:getHeight()

    for row = 0, math.floor(imgH / frameHeight) - 1 do
        for col = 0, math.floor(imgW / frameWidth) - 1 do
            table.insert(self._frames, love.graphics.newQuad(
                col * frameWidth,
                row * frameHeight,
                frameWidth,
                frameHeight,
                imgW,
                imgH
            ))
        end
    end

    self:centerHitbox()
end

---Load a list of separate images as frames
---@param imageList table love.Image[]
function Object:setFrames(imageList)
    self._frames      = imageList
    self._image       = nil
    self._mode        = "frames"
    self._frameWidth  = imageList[1]:getWidth()
    self._frameHeight = imageList[1]:getHeight()

    self:centerHitbox()
end

---Set a single static image (no animation)
---@param image love.Image
function Object:setSprite(image)
    self._image       = image
    self._mode        = "static"
    self._frameWidth  = image:getWidth()
    self._frameHeight = image:getHeight()
    self._frames      = {}

    self:centerHitbox()
end

--------------------------------------------------------------------------------
-- Coordinate
--------------------------------------------------------------------------------

function Object:screenCenter()
    self.x = shove.getViewportWidth() * 0.5
    self.y = shove.getViewportHeight() * 0.5
end

function Object:setSize(sx, sy)
    self.scaleX = sx or 1
    self.scaleY = sy or 1
end

function Object:setOrigin(ox, oy)
    self.originX = ox or 0
    self.originY = oy or 0
end

function Object:centerOrigin()
    self.originX = self._frameWidth * 0.5
    self.originY = self._frameHeight * 0.5
end

function Object:setScrollFactor(x, y)
    self.scrollFactor.x = x or 1
    self.scrollFactor.y = y or 1
end

--------------------------------------------------------------------------------
-- Hitbox
--------------------------------------------------------------------------------

---Set hitbox manually with optional offset relative to the object origin
---@param w number
---@param h number
---@param offsetX number|nil
---@param offsetY number|nil
function Object:setHitbox(w, h, offsetX, offsetY)
    self.hitbox.w = w
    self.hitbox.h = h
    self.hitbox.x = offsetX or 0
    self.hitbox.y = offsetY or 0
end

---Center the hitbox based on current frame size
function Object:centerHitbox()
    self.hitbox.w = self._frameWidth
    self.hitbox.h = self._frameHeight
    self.hitbox.x = 0
    self.hitbox.y = 0
end

---Get the hitbox in world space
---@return table { x, y, w, h }
function Object:getWorldHitbox()
    return {
        x = self.x + self.hitbox.x,
        y = self.y + self.hitbox.y,
        w = self.hitbox.w,
        h = self.hitbox.h,
    }
end

--------------------------------------------------------------------------------
-- Animation
--------------------------------------------------------------------------------

---Add a named animation
---@param name string
---@param frames table|"all" list of frame indices (1-based), or "all" to use every frame currently loaded (self._frames)
---@param fps number
---@param loop boolean
function Object:addAnimation(name, frames, fps, loop)
    if frames == "all" then
        frames = {}
        for i = 1, #self._frames do
            frames[i] = i
        end
    end

    self._animations[name] = {
        frames = frames,
        fps    = fps,
        loop   = (loop == nil) and true or loop,
    }
end

---Play a named animation
---@param name string
---@param forceRestart boolean|nil
function Object:play(name, forceRestart)
    local anim = self._animations[name]
    if not anim then
        error("[Object] : Animation '" .. name .. "' not found.")
    end

    if self._currentAnim == anim and not forceRestart then return end

    self._currentAnim  = anim
    self._currentFrame = 1
    self._timer        = 0
    self._finished     = false
end

---Stop the current animation on the current frame
function Object:stop()
    self._currentAnim = nil
end

---Returns true if the current animation finished (non-looping)
---@return boolean
function Object:isFinished()
    return self._finished
end

---Returns the name of the current animation
---@return string|nil
function Object:currentAnimation()
    for name, anim in pairs(self._animations) do
        if anim == self._currentAnim then return name end
    end
    return nil
end

function Object:setFrame(num)
    self._currentFrame = num
end

--------------------------------------------------------------------------------
-- Update / Draw
--------------------------------------------------------------------------------

function Object:update(dt)
    if self._destroyed then return end
    if not self.active then return end
    if not self._currentAnim then return end

    local anim = self._currentAnim
    self._timer = self._timer + dt

    local frameDuration = 1 / anim.fps

    while self._timer >= frameDuration do
        self._timer = self._timer - frameDuration
        self._currentFrame = self._currentFrame + 1

        if self._currentFrame > #anim.frames then
            if anim.loop then
                self._currentFrame = 1
            else
                self._currentFrame = #anim.frames
                self._finished = true
                break
            end
        end
    end
end

function Object:draw()
    if self._destroyed then return end
    if not self.visible then return end
    if not self._image and self._mode ~= "frames" then return end

    local frameIndex = self._currentAnim
        and self._currentAnim.frames[self._currentFrame]
        or 1

    local sx = self.scaleX * (self.flipX and -1 or 1)
    local sy = self.scaleY * (self.flipY and -1 or 1)
    local ox = self.originX
    local oy = self.originY

    love.graphics.setColor(1, 1, 1, self.alpha)

    love.graphics.setBlendMode(self.drawMode)
    if self._mode == "spritesheet" then
        local quad = self._frames[frameIndex]
        if quad then
            love.graphics.draw(self._image, quad, self.x, self.y, self.angle, sx, sy, ox, oy)
        end
    elseif self._mode == "frames" then
        local img = self._frames[frameIndex]
        if img then
            love.graphics.draw(img, self.x, self.y, self.angle, sx, sy, ox, oy)
        end
    elseif self._mode == "static" then
        love.graphics.draw(self._image, self.x, self.y, self.angle, sx, sy, ox, oy)
    end
    love.graphics.setBlendMode("alpha")

    love.graphics.setColor(1, 1, 1, 1)
end

function Object:destroy()
    self._destroyed = true
end

--------------------------------------------------------------------------------

return Object
